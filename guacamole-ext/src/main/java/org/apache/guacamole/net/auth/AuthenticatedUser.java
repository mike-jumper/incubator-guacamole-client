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

package org.apache.guacamole.net.auth;


/**
 * A user of the Guacamole web application who has been authenticated by an
 * AuthenticationProvider.
 */
public interface AuthenticatedUser extends Identifiable {

    /**
     * The identifier reserved for representing a user that has authenticated
     * anonymously.
     */
    public static final String ANONYMOUS_IDENTIFIER = "";

    /**
     * Returns the unique authentication token generated for this authenticated
     * user. This token will be used in all subsequent requests to represent
     * the user.
     *
     * @return
     *     The unique authentication token generated for this authenticated
     *     user.
     */
    String getToken();

    /**
     * Returns the AuthenticationProvider that authenticated this user.
     *
     * @return
     *     The AuthenticationProvider that authenticated this user.
     */
    AuthenticationProvider getAuthenticationProvider();

    /**
     * Returns the credentials that the user provided when they successfully
     * authenticated.
     *
     * @return
     *     The credentials provided by the user when they authenticated.
     */
    Credentials getCredentials();

}
