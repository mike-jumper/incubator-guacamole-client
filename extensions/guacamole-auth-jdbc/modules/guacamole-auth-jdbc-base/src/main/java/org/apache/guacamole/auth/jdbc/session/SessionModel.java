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

import java.sql.Timestamp;
import org.apache.guacamole.auth.jdbc.base.ObjectModel;

/**
 * Object representation of a Guacamole session associated with an
 * authenticated user, identified by a unique authentication token.
 */
public class SessionModel extends ObjectModel {

    /**
     * The database ID of the user associated with this session.
     */
    private Integer userID;

    /**
     * The username of the user associated with this session.
     */
    private String username;

    /**
     * The IP address or hostname of the remote machine that the user
     * authenticated from.
     */
    private String remoteHost;

    /**
     * The time that this session was last used.
     */
    private Timestamp lastUsed;

    /**
     * Creates a new, empty session.
     */
    public SessionModel() {
    }

    /**
     * Returns the database ID of the user associated with this session.
     *
     * @return
     *     The database ID of the user associated with this session.
     */
    public Integer getUserID() {
        return userID;
    }

    /**
     * Sets the database ID of the user associated with this session.
     *
     * @param userID
     *     The database ID of the user associated with this session.
     */
    public void setUserID(Integer userID) {
        this.userID = userID;
    }

    /**
     * Returns the username of the user associated with this session.
     *
     * @return
     *     The username of the user associated with this session.
     */
    public String getUsername() {
        return username;
    }

    /**
     * Sets the username of the user associated with this session.
     *
     * @param username
     *     The username of the user associated with this session.
     */
    public void setUsername(String username) {
        this.username = username;
    }

    /**
     * Returns the IP address or hostname of the remote machine that the user
     * authenticated from.
     *
     * @return
     *     The IP address or hostname of the remote machine that the user
     *     authenticated from.
     */
    public String getRemoteHost() {
        return remoteHost;
    }

    /**
     * Sets the IP address or hostname of the remote machine that the user
     * authenticated from.
     *
     * @param remoteHost
     *     The IP address or hostname of the remote machine that the user
     *     authenticated from.
     */
    public void setRemoteHost(String remoteHost) {
        this.remoteHost = remoteHost;
    }

    /**
     * Returns the time that this session was last used.
     *
     * @return
     *    The time that this session was last used.
     */
    public Timestamp getLastUsed() {
        return lastUsed;
    }

    /**
     * Sets the time that this session was last used.
     *
     * @param lastUsed
     *    The time that this session was last used.
     */
    public void setLastUsed(Timestamp lastUsed) {
        this.lastUsed = lastUsed;
    }

}
