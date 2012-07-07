using Gtk;

extern const string GETTEXT_PACKAGE;

void main(string[] args) {
	stdout.printf ("%s\n", GETTEXT_PACKAGE);
	stdout.printf (_("Hello World!\n"));
	OptionEntry[]? entries = null;
	OptionEntry terminator = { null, 0, 0, 0, null, null, null };
	entries += terminator;
	try {
		Gtk.init_with_args(ref args, _("[FILE]"), entries,
			GETTEXT_PACKAGE);
	} catch (Error e) {
		stdout.printf("error %s\n", e.message);
	}
	
	stdout.printf (_("Hello World!\n"));
}
