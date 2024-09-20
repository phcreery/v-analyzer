module analyzer

import analyzer.index

fn on_start_fn(root index.IndexingRoot, idx int) {
	println('${root} - ${idx}')
}

fn test_complex_index() {
	mut indexer := new_indexer()
	indexer.add_indexing_root('C:/Users/phcre/Documents/v/imageeditor', .workspace, 'C:/temp')
	status := indexer.index(on_start_fn)
	println(status)
	// dump(indexer)
}

