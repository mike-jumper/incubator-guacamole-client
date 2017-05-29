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

package org.apache.guacamole.net.auth.token;

import java.security.SecureRandom;
import javax.xml.bind.DatatypeConverter;

/**
 * A TokenGenerator implementation which uses a secure source of random numbers
 * to generate 256-bit hexadecimal authentication tokens. This class is
 * threadsafe. A single instance of this class may be shared by multiple
 * threads.
 */
public class SecureRandomTokenGenerator implements TokenGenerator {

    /**
     * Instance of SecureRandom for generating authentication tokens.
     */
    private final SecureRandom secureRandom = new SecureRandom();

    /**
     * Singleton instance of this class.
     */
    private static final SecureRandomTokenGenerator instance =
            new SecureRandomTokenGenerator();

    /**
     * Returns a singleton instance of the SecureRandomTokenGenerator.
     *
     * @return
     *     A singleton instance of the SecureRandomTokenGenerator.
     */
    public static SecureRandomTokenGenerator getInstance() {
        return instance;
    }

    @Override
    public String getToken() {
        byte[] bytes = new byte[32];
        secureRandom.nextBytes(bytes);
        return DatatypeConverter.printHexBinary(bytes);
    }

}
