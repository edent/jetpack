/**
 * External dependencies
 */

/**
 * WordPress dependencies
 */
import { addFilter } from '@wordpress/hooks';

/**
 * Internal dependencies
 */
import coverEditMediaPlaceholder from './cover-media-placeholder';
import coverMediaReplaceFlow from './cover-replace-control-button';
import jetpackCoverBlockEdit from './edit';
import './editor.scss';

// Take the control of the Replace block button control.
addFilter( 'editor.MediaReplaceFlow', 'jetpack/cover-media-replace-flow', coverMediaReplaceFlow );
addFilter(
	'editor.MediaPlaceholder',
	'jetpack/cover-edit-media-placeholder',
	coverEditMediaPlaceholder
);
addFilter( 'blocks.registerBlockType', 'jetpack/cover-block-edit', jetpackCoverBlockEdit );
