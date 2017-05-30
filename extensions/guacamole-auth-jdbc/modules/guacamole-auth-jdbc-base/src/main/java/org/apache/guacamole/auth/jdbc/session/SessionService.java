/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package org.apache.guacamole.auth.jdbc.session;

import com.google.inject.Inject;
import java.sql.Timestamp;
import org.apache.guacamole.GuacamoleException;
import org.apache.guacamole.auth.jdbc.JDBCEnvironment;
import org.apache.guacamole.auth.jdbc.user.ModeledAuthenticatedUser;
import org.apache.guacamole.net.auth.Credentials;
import org.apache.ibatis.exceptions.PersistenceException;
import org.mybatis.guice.transactional.Transactional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Service which provides convenience methods maintaining user session objects.
 */
public class SessionService {

    /**
     * Logger for this class.
     */
    private static final Logger logger = LoggerFactory.getLogger(SessionService.class);

    /**
     * The Guacamole server environment.
     */
    @Inject
    private JDBCEnvironment environment;

    /**
     * Mapper for accessing active session information.
     */
    @Inject
    private SessionMapper sessionMapper;

    /**
     * Returns a reasonable subset of the Credentials used when the user
     * associated with the given authentication token authenticated, if the
     * token is valid. Not all properties of the resulting Credentials object
     * may be available, even if they were available at the time that the user
     * authenticated.
     *
     * @param token
     *     The authentication token of the user whose Credentials should be
     *     retrieved.
     *
     * @return
     *     A reasonable subset of the Credentials used by the user when they
     *     authenticated, or null if the authentication token is invalid.
     *
     * @throws GuacamoleException
     *     If the Guacamole server's session timeout value cannot be read.
     */
    @Transactional
    public Credentials retrieveCredentials(String token)
            throws GuacamoleException {

        // Pull session from database, if it exists
        SessionModel sessionModel = sessionMapper.select(token);
        if (sessionModel == null)
            return null;

        // Calculate the time this token expires
        long lastUsed = sessionModel.getLastUsed().getTime();
        long expires = lastUsed + environment.getSessionTimeout() * 60000L;

        // If token has expired, return nothing
        if (expires <= System.currentTimeMillis())
            return null;

        // Populate credentials with stored token information
        Credentials credentials = new Credentials();
        credentials.setUsername(sessionModel.getUsername());
        credentials.setRemoteAddress(sessionModel.getRemoteHost());
        credentials.setRemoteHostname(sessionModel.getRemoteHost());
        credentials.setToken(sessionModel.getIdentifier());

        return credentials;

    }

    /**
     * Stores a reasonable subset of the Credentials used by the given
     * authenticated user within the database, such that they can be retrieved
     * through future calls to retrieveCredentials().
     *
     * @param authenticatedUser
     *     The authenticated user whose Credentials should be stored.
     */
    @Transactional
    public void storeAuthenticationResult(ModeledAuthenticatedUser authenticatedUser) {

        // Pull credentials and token from authenticated user
        Credentials credentials = authenticatedUser.getCredentials();
        String token = authenticatedUser.getToken();

        // Create session object
        SessionModel sessionModel = new SessionModel();
        sessionModel.setIdentifier(token);
        sessionModel.setRemoteHost(credentials.getRemoteAddress());
        sessionModel.setUserID(authenticatedUser.getUser().getModel().getObjectID());
        sessionModel.setLastUsed(new Timestamp(System.currentTimeMillis()));

        // Update stored values if the session object already exists
        int updated = sessionMapper.touch(sessionModel);
        if (updated == 0) {

            // If the stored values do not yet exist, try to insert
            try {
                sessionMapper.insert(sessionModel);
            }

            // Ignore any failure to insert (likely due to a duplicate key from
            // a previous request, in which case the values should already be
            // present)
            catch (PersistenceException e) {
                logger.debug("Ignoring failed INSERT of session.", e);
            }

        }

    }

    /**
     * Invalidates the user session associated with the given authentication
     * token, removing it from the database entirely.
     *
     * @param token
     *     The authentication token of the session to invalidate.
     */
    @Transactional
    public void invalidate(String token) {
        sessionMapper.delete(token);
    }

}
