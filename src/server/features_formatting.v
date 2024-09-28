module server

import lsp
import os
import server.tform
import loglib

const temp_formatting_file_path = os.join_path(os.temp_dir(), 'v-analyzer-formatting-temp.v')

pub fn (mut ls LanguageServer) formatting(params lsp.DocumentFormattingParams) ![]lsp.TextEdit {
	uri := params.text_document.uri.normalize()
	file := ls.get_file(uri) or { return error('Cannot format not opened file') }

	os.write_file(temp_formatting_file_path, file.psi_file.source_text) or {
		return error('Cannot write temp file for formatting: ${err}')
	}

	loglib.info('Formatting file: ${temp_formatting_file_path} ${file.uri}')

	mut fmt_proc := ls.launch_tool('fmt', os.norm_path(temp_formatting_file_path)) or { return [] }
	defer {
		fmt_proc.close()
	}
	fmt_proc.run()

	loglib.info('Formatting finished with code: ${fmt_proc.code}')

	// read entire output until EOF
	mut output := fmt_proc.stdout_slurp()

	// fmt_proc.wait()
	// OR
	fmt_proc.close()

	$if windows {
		output = output.replace('\r\r', '\r')
	}

	if (fmt_proc.code != 0) && (fmt_proc.status == .exited) {
		errors := fmt_proc.stderr_slurp().trim_space()
		ls.client.show_message(errors, .info)
		return error('Formatting failed: ${errors}')
	}


	return [
		lsp.TextEdit{
			range:    tform.text_range_to_lsp_range(file.psi_file.root().text_range())
			new_text: output
		},
	]
}
