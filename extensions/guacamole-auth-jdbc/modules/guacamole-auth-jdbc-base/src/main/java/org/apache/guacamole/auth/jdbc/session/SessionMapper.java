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

import org.apache.ibatis.annotations.Param;

/**
 * Mapper for user session objects.
 */
public interface SessionMapper {

    /**
     * Returns the user session object associated with the given
     * authentication token.
     *
     * @param token
     *     The authentication token of the user session to be retrieved.
     *
     * @return
     *     The user session object associated with the given authentication
     *     token, or null if no such user session exists.
     */
    SessionModel select(@Param("token") String token);

    /**
     * Inserts the given user session object.
     *
     * @param session
     *     The user session object to insert.
     *
     * @return
     *     The number of rows inserted.
     */
    int insert(@Param("session") SessionModel session);

    /**
     * Updates the last-used timestamp of the given user session object, if
     * it exists.
     *
     * @param session
     *     The user session object to update.
     *
     * @return
     *     The number of rows updated, which will be non-zero if the user
     *     session object was updated.
     */
    int touch(@Param("session") SessionModel session);

    /**
     * Deletes the user session object associated with the given
     * authentication token.
     *
     * @param token
     *     The authentication token of the user session to be deleted.
     *
     * @return
     *     The number of rows deleted.
     */
    int delete(@Param("token") String token);
    
}
