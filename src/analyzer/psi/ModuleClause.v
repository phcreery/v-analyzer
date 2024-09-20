module psi

import os

pub struct ModuleClause {
	PsiElementImpl
}

fn (_ &ModuleClause) stub() {}

pub fn (_ &ModuleClause) is_public() bool {
	return true
}

fn (n &ModuleClause) identifier() ?PsiElement {
	return n.find_child_by_type(.identifier)
}

pub fn (n &ModuleClause) identifier_text_range() TextRange {
	if stub := n.get_stub() {
		return stub.identifier_text_range
	}

	identifier := n.identifier() or { return TextRange{} }
	return identifier.text_range()
}

pub fn (n ModuleClause) name() string {
	if stub := n.get_stub() {
		return stub.name
	}

	identifier := n.identifier() or { return '' }
	return identifier.get_text()
}

pub fn module_qualified_name(file &PsiFile, indexing_root string) string {
	println('module_qualified_name(${indexing_root}) entry')
	module_name := file.module_name() or { '' }
	println('module_qualified_name(${indexing_root}) =${module_name}')
	if module_name in ['main', 'builtin'] {
		println('module_qualified_name(${indexing_root}) =${module_name} returning')
		return module_name
	}
	if module_name == '' && file.is_test_file() {
		println('module_qualified_name(${indexing_root}) =${module_name} returning')
		return ''
	}

	// mut root_dirs := [indexing_root]
	mut root_dirs := [os.norm_path(indexing_root)]

	// src_dir := os.join_path(indexing_root, 'src')
	src_dir := os.norm_path(os.join_path(indexing_root, 'src'))
	if os.exists(src_dir) {
		root_dirs << src_dir
	}

	containing_dir := os.dir(file.path)
	println('module_qualified_name(${indexing_root}) =${module_name} got containing_dir')

	mut module_names := []string{}

	println('module_qualified_name(${indexing_root}) =${module_name} checking root_dirs ${root_dirs}')
	mut dir := containing_dir
	for dir != '' && dir !in root_dirs && dir != '.' {
		println('module_qualified_name(${indexing_root}) =${module_name} adding dir ${dir}')
		module_names << os.file_name(dir)
		dir = os.dir(dir)
		// println('module_qualified_name(${indexing_root}) =${module_name}  added dir ${dir}')
	}
	println('module_qualified_name(${indexing_root}) =${module_name} got module_names ${module_names}')

	module_names.reverse_in_place()

	if module_names.len == 0 {
		println('module_qualified_name(${indexing_root}) =${module_name} returning .len=0 ${module_name}')
		return module_name
	}

	if module_names.first() == 'builtin' {
		module_names = module_names[1..].clone()
	}

	if module_names.len != 0 && module_names.last() == module_name {
		module_names = module_names[..module_names.len - 1].clone()
	}

	qualifier := module_names.join('.')
	if qualifier == '' {
		println('module_qualified_name(${indexing_root}) =${module_name} returning ${module_name}')
		return module_name
	}

	if module_name == '' {
		println('module_qualified_name(${indexing_root}) =${module_name} returning ${qualifier}')
		return qualifier
	}

	println('module_qualified_name(${indexing_root}) =${module_name} returning ${qualifier + '.' + module_name}')

	return qualifier + '.' + module_name
}
