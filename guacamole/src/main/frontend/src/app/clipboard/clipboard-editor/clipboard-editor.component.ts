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

import {
    Component,
    EventEmitter,
    Input,
    OnChanges,
    Output,
    SimpleChanges
} from '@angular/core';

import { ClipboardData } from 'app/clipboard/clipboard-data';

/**
 * A component that provides an editor whose contents are exposed via a
 * ClipboardData object via the "data" attribute. If this data should also be
 * synced to the local clipboard, or sent via a connected Guacamole client,
 * it is up to external code to do so.
 */
@Component({
    selector: 'guac-clipboard-editor',
    templateUrl: './clipboard-editor.component.html',
    styleUrls: ['./clipboard-editor.component.less']
})
export class ClipboardEditorComponent implements OnChanges {

    /**
     * The data to display within the editor provided by this directive.
     */
    @Input()
    data! : ClipboardData;

    /**
     * Event emitter for producing the "dataChange" event after clipboard data
     * has been changed through the editor.
     */
    @Output()
    dataChange = new EventEmitter<ClipboardData>();

    /**
     * The current text contents of the editor, as displayed with the textarea.
     */
    clipboardText! : string;

    /**
     * Rereads the contents of the clipboard field, updating the
     * ClipboardData object on the scope as necessary. The type of data
     * stored within the ClipboardData object will be heuristically
     * determined from the HTML contents of the clipboard field.
     */
    updateClipboardData(): void {

        this.data = new ClipboardData({
            type : 'text/plain',
            data : this.clipboardText
        });

        this.dataChange.emit(this.data);

    }

    // Watch clipboard for new data, updating the clipboard textarea as
    // necessary
    ngOnChanges(changes: SimpleChanges): void {
        if ('data' in changes) {

            const clipboard = changes.data.currentValue;

            // If the clipboard data is a string, render it as text
            if (typeof clipboard.data === 'string')
                this.clipboardText = clipboard.data;

            // Ignore other data types for now

        }
    }

}
