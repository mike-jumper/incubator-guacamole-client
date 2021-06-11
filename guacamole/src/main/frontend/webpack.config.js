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

const AngularTemplateCacheWebpackPlugin = require('angular-templatecache-webpack-plugin');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const CopyPlugin = require('copy-webpack-plugin');
const DependencyListPlugin = require('./plugins/dependency-list-plugin');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const webpack = require('webpack');

module.exports = {

    module: {
        rules: [

            // Automatically extract imported CSS for later reference within separate CSS file
            {
                test: /\.css$/i,
                use: [
                    MiniCssExtractPlugin.loader,
                    {
                        loader: 'css-loader',
                        options: {
                            import: false,
                            url: false
                        }
                    }
                ]
            },

            /*
             * Necessary to be able to use angular 1 with webpack as explained in https://github.com/webpack/webpack/issues/2049
             */
            {
                test: require.resolve('angular'),
                loader: 'exports-loader',
                options: {
                    type: 'commonjs',
                    exports: 'single window.angular'
                }
            }

        ]
    },
    plugins: [

        new AngularTemplateCacheWebpackPlugin({
            module: 'templates-main',
            root: 'app/',
            source: 'src/app/**/*.html',
            standalone: true
        }),

        // Automatically clean out dist/ directory
        new CleanWebpackPlugin(),

        // Copy static files to dist/
        new CopyPlugin([
            { from: 'app/**/*' },
            { from: 'fonts/**/*' },
            { from: 'images/**/*' },
            { from: 'layouts/**/*' },
            { from: 'translations/**/*' }
        ], {
            context: 'src/'
        }),

        // Copy core libraries for global inclusion
        new CopyPlugin([
            { from: 'angular/angular.min.js' },
            { from: 'blob-polyfill/Blob.js' },
            { from: 'datalist-polyfill/datalist-polyfill.min.js' },
            { from: 'jquery/dist/jquery.min.js' },
            { from: 'lodash/lodash.min.js' }
        ], {
            context: 'node_modules/'
        }),

        // List all bundled node modules for sake of automatic LICENSE file
        // generation / sanity checks
        new DependencyListPlugin(),

        // Automatically require used modules
        new webpack.ProvidePlugin({
            jstz: 'jstz',
            Pickr: '@simonwep/pickr',
            saveAs: 'file-saver'
        })

    ],
    resolve: {

        // Include Node modules and base source tree within search path for
        // import/resolve
        modules: [
            'src',
            'node_modules'
        ]

    }

};

