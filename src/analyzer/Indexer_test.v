module analyzer
import analyzer.index
fn on_start_fn(root index.IndexingRoot, idx int) {
	println('Indexing (${idx}) ${root.root}')
}
fn test_index_dot() {
	mut indexer := new_indexer()
	indexer.add_indexing_root('.', .workspace, '~/.cache/v-analyzer')
	status := indexer.index(on_start_fn)
	assert status == .all_indexed
}
fn test_index_fs() {
	mut indexer := new_indexer()
	indexer.add_indexing_root('./', .workspace, '~/.cache/v-analyzer')
	status := indexer.index(on_start_fn)
	assert status == .all_indexed
}
fn test_index_bs() {
	mut indexer := new_indexer()
	indexer.add_indexing_root('.\\', .workspace, '~/.cache/v-analyzer')
	status := indexer.index(on_start_fn)
	assert status == .all_indexed
}

fn test_index_local() {
	mut indexer := new_indexer()
	indexer.add_indexing_root('C:/Users/phcre/Documents/v/imageeditor', .workspace, '~/.cache/v-analyzer')
	status := indexer.index(on_start_fn)
	assert status == .all_indexed
}