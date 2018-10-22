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

var Guacamole = Guacamole || {};

/**
 * Represents an arbitrary language as may be defined by a language tag
 * following RFC 5646 (BCP 47). All properties which correspond to subtags
 * defined within RFC 5646 will be automatically converted to follow the case
 * conventions dictated by that standard.
 *
 * @see {@link https://tools.ietf.org/html/rfc5646}
 *
 * @constructor
 * @param {Guacamole.Language|Object} template
 *     The object whose properties should be copied into the corresponding
 *     properties of the newly-created Guacamole.Language.
 */
Guacamole.Language = function Language(template) {

    /**
     * Reference to this Guacamole.Language.
     *
     * @private
     * @type {Guacamole.Language}
     */
    var lang = this;

    /**
     * Converts the given string to UPPERCASE. If the string provided is null
     * or undefined, that value is passed through untouched.
     *
     * @private
     * @param {String} str
     *     The string to convert to uppercase.
     *
     * @returns {String}
     *     The uppercase version of the given string if a non-null string is
     *     provided, the provided value otherwise.
     */
    var upper = function upper(str) {
        return str ? str.toUpperCase() : str;
    };

    /**
     * Converts the given string to lowercase. If the string provided is null
     * or undefined, that value is passed through untouched.
     *
     * @private
     * @param {String} str
     *     The string to convert to lowercase.
     *
     * @returns {String}
     *     The lowercase version of the given string if a non-null string is
     *     provided, the provided value otherwise.
     */
    var lower = function lower(str) {
        return str ? str.toLowerCase() : str;
    };

    /**
     * Converts the given string to Title case. The first character of the
     * given string is converted to uppercase, while all other characters are
     * converted to lowercase. If the string provided is null or undefined,
     * that value is passed through untouched.
     *
     * @private
     * @param {String} str
     *     The string to convert to title case.
     *
     * @returns {String}
     *     The title case version of the given string if a non-null string is
     *     provided, the provided value otherwise.
     */
    var title = function title(str) {
        return str ? str.substring(0, 1).toUpperCase() + str.substring(1).toLowerCase() : str;
    };

    /**
     * The value of the primary language subtag for this language as defined by
     * RFC 5646. This will typically be a 2-letter language code and is
     * lowercase.
     *
     * @see {@link https://tools.ietf.org/html/rfc5646#section-2.2.1}
     * @type {String}
     */
    this.primaryLanguage = lower(template.primaryLanguage);

    /**
     * The value of the extended language subtag for this language as defined
     * by RFC 5646. This will be a 3-letter language code which further narrows
     * the primary language and is lowercase. This subtag is omitted when it
     * does not serve to further distinguish the language from other
     * variations. If the value of this subtag is omitted or unknown, this will
     * be null.
     *
     * @see {@link https://tools.ietf.org/html/rfc5646#section-2.2.2}
     * @type {String}
     */
    this.extendedLanguage = lower(template.extendedLanguage);

    /**
     * The value of the script subtag for this language as defined by RFC 5646.
     * This will typically be a 4-letter code representing the writing system
     * which applies to this language and is Title case. This subtag is omitted
     * when it does not serve to further distinguish the language from other
     * variations. If the value of this subtag is omitted or unknown, this will
     * be null.
     *
     * @see {@link https://tools.ietf.org/html/rfc5646#section-2.2.3}
     * @type {String}
     */
    this.script = title(template.script);

    /**
     * The value of the region subtag for this language as defined by RFC 5646.
     * This will typically be a 2-letter country code and is UPPERCASE. This
     * subtag is omitted when it does not serve to further distinguish the
     * language from other variations. If the value of this subtag is omitted
     * or unknown, this will be null.
     *
     * @see {@link https://tools.ietf.org/html/rfc5646#section-2.2.4}
     * @type {String}
     */
    this.region = upper(template.region);

    /**
     * Converts this Guacamole.Language into the corresponding locale value
     * which would be assigned to the LANG or LC_* variables defined by POSIX.
     * The value returned by this function will be in the format "xx" or
     * "xx_YY", where "xx" is the lowercase 2-letter language code
     * corresponding to the primary language and "YY" is the uppercase country
     * code corresponding to the region (if defined).
     *
     * @see {@link http://pubs.opengroup.org/onlinepubs/7908799/xbd/envvar.html#tag_002_002}
     * @returns {String}
     *     A string which contains the locale value corresponding to this
     *     Guacamole.Language which would be assigned to the LANG or LC_*
     *     variables defined by POSIX.
     */
    this.toPOSIX = function toPOSIX() {

        if (lang.region)
            return lang.primaryLanguage + '_' + lang.region;

        return lang.primaryLanguage;

    };

};

/**
 * Creates a new Guacamole.Language which represents the language described by
 * the given language tag. The language tag must be in the format specified by
 * RFC 5646 (BCP 47).
 *
 * @see {@link https://tools.ietf.org/html/rfc5646}
 *
 * @param {String} tag
 *     The RFC 5646 language tag to parse.
 *
 * @returns {Guacamole.Language}
 *     A new Guacamole.Language which represents the language described buy the
 *     given RFC 5646 language tag.
 */
Guacamole.Language.parseTag = function parseTag(tag) {

    // Split given language tag into all subtags as defined by RFC 5646
    var subtags = tag.split('-');

    /**
     * Shifts the first element from the given string array only if it matches
     * the given regular expression. If the first element does not exist (the
     * array is empty) or does not match, null is returned.
     *
     * @param {String[]} arr
     *     The array to conditionally shift the first element from. This array
     *     will be modified as a result of this operation if the first element
     *     matches.
     *
     * @param {RegExp} regex
     *     The regular expression to test the first element against.
     *
     * @returns {String}
     *     The first element of the array if the first element matches the
     *     regular expression, null otherwise.
     */
    var shiftMatch = function shiftMatch(arr, regex) {

        if (arr.length && regex.test(arr[0]))
            return arr.shift();

        return null;

    };

    // The first subtag is always the primary language subtag and is required
    // in all cases
    var primaryLanguage = shiftMatch(subtags, /^[a-zA-Z]{2,3}$/);
    if (!primaryLanguage)
        return null;

    // Any 3-letter subtag following the primary language subtag is the
    // extended language subtag
    var extendedLanguage = shiftMatch(subtags, /^[a-zA-Z]{3}$/);

    // There are up to two 3-letter subtags following the extended language
    // subtag which are reserved for future/private use by RFC 5646 and should
    // be ignored if present
    if (extendedLanguage) {
        for (var i = 0; i < 2; i++)
            shiftMatch(subtags, /^[a-zA-Z]{3}$/);
    }

    // After the primary/extended language subtags, any 4-letter subtag is the
    // script subtag
    var script = shiftMatch(subtags, /^[a-zA-Z]{4}$/);

    // Following the primary, extended, and script subtags, and 2-letter or
    // 3-digit subtag is the region subtag
    var region = shiftMatch(subtags, /^([a-zA-Z]{2}|[0-9]{3})$/);

    // Build a Guacamole.Language using the parsed values
    return new Guacamole.Language({
        primaryLanguage : primaryLanguage,
        extendedLanguage : extendedLanguage,
        script : script,
        region : region
    });

};

/**
 * Retrieves the language currently in use within the browser. This language
 * may have been set by a system-level setting, by a preference within the
 * browser, or may not have been set at all. If the browser does not have a
 * language set or does not expose that language, the Guacamole.Language
 * corresponding to the given default language is returned, or null if no
 * default is provided.
 *
 * @param {String} [defaultLanguage]
 *     The RFC 5646 language tag of the language to return by default if the
 *     browser does not define a current language, does not support retrieving
 *     the current language, or does not provide the current language in the
 *     correct format.
 *
 * @returns {Guacamole.Language}
 *     A new Guacamole.Language representing the language currently in use
 *     within the browser if the browser supports retrieving this value, a
 *     Guacamole.Language representing the given default language if the
 *     current language cannot be retrieved and a default was provided, null
 *     otherwise.
 */
Guacamole.Language.getCurrent = function getCurrent(defaultLanguage) {

    // Pull browser language if possible
    var language = (navigator.languages && navigator.languages[0])
                 || navigator.language
                 || navigator.browserLanguage
                 || defaultLanguage;

    // Parse language if successfully retrieved
    return language && Guacamole.Language.parseTag(language);

};
