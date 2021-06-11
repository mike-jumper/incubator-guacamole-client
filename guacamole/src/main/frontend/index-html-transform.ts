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

import { TargetOptions } from '@angular-builders/custom-webpack';

/**
 * Inserts arbitrary HTML before a given search term within existing HTML. Note
 * that the pattern matching performed to locate the search term is not
 * syntax-aware. The search term MUST NOT occur anywhere else within the HTML.
 *
 * @param {string} html
 *     The HTML that should be modified.
 *
 * @param {string} searchTerm
 *     The text before which the provided HTML should be inserted.
 *
 * @param {string} additionalHtml
 *     The additional HTML to insert before the search term.
 *
 * @return {string}
 *     The provided HTML with the additional HTML inserted before the search
 *     term.
 */
const insertBefore = (html: string, searchTerm: string, additionalHtml: string) => {

    const searchIndex = html.indexOf(searchTerm);

    return `
        ${html.slice(0, searchIndex)}
        ${additionalHtml}
        ${html.slice(searchIndex)}
    `;

}

export default (targetOptions: TargetOptions, indexHtml: string) => {

    let updatedHtml = indexHtml;

    // Include extension JavaScript after all other JS, including Angular, to
    // ensure extensions can leverage/override built-in functionality
    updatedHtml = insertBefore(updatedHtml, '</body>',
        '<script type="text/javascript" src="app.js?v=${project.version}" defer></script>');

    // Insert CSS at end of head such that extension CSS can override
    // built-in CSS
    updatedHtml = insertBefore(updatedHtml, '</head>',
        '<link rel="stylesheet" type="text/css" href="app.css?v=${project.version}">');

    return updatedHtml;

};

