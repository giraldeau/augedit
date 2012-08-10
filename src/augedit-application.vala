/* Copyright 2012 Francis Giraldeau
 *
 * This software is licensed under the GNU General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution. 
 */

using Gtk;
using GLib;

extern const string GETTEXT_PACKAGE;

// Defined by CMake build script.
extern const string _VERSION;
extern const string _INSTALL_PREFIX;
extern const string _GSETTINGS_DIR;
extern const string _SOURCE_ROOT_DIR;

public class AugeditApplication : Window {

    private TreeView tree_view;
    private AugeditLoader loader;
    private Box container;
    private ScrolledWindow scroll;
    private Spinner spinner;
    private Table spinner_widget;
    private Box vbox;
    
    public AugeditApplication() {
        this.title = _("Augeas configuration editor\n");
        this.window_position = WindowPosition.CENTER;
        set_default_size(400, 300);
        
        var toolbar = new Toolbar();
        toolbar.get_style_context().add_class(STYLE_CLASS_PRIMARY_TOOLBAR);
        
        this.tree_view = new TreeView();
        this.tree_view.insert_column_with_attributes(-1, "Key",
            new CellRendererText(), "text", AugeditLoader.Columns.KEY, null);
        this.tree_view.insert_column_with_attributes(-1, "Value",
            new CellRendererText(), "text", AugeditLoader.Columns.VALUE, null);
        scroll = new ScrolledWindow(null, null);
        scroll.set_policy(PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
        scroll.add(this.tree_view);
        
        spinner = new Spinner();
        var spinner_label = new Label(_("Loading..."));
        var box = new Box(Orientation.HORIZONTAL, 5);
        box.pack_start(spinner, true, true, 5);
        box.pack_start(spinner_label, true, true, 5);
        spinner_widget = new Table(3, 3, true);
        spinner_widget.attach(box, 1, 2, 1, 2, AttachOptions.EXPAND, AttachOptions.FILL, 3, 3);
        
        container = new Box(Orientation.VERTICAL, 0);
        
        vbox = new Box(Orientation.VERTICAL, 0);
        vbox.pack_start(toolbar, false, true, 0);
        vbox.pack_start(container, true, true, 0);
        add(vbox);
    }

    public void show_spinner(bool enable) {
        if (enable && spinner_widget.get_parent() == null) {
            container.remove(scroll);
            container.pack_start(spinner_widget, true, false, 0);
            spinner_widget.show_all();
            spinner.start();
        }
        if (!enable && spinner_widget.get_parent() != null) {
            container.remove(spinner_widget);
            container.pack_start(scroll, true, true, 0);
            scroll.show_all();
            spinner.stop();
        }
    }
    
    public void load_augeas() {
        show_spinner(true);
        this.loader = new AugeditLoader();
        loader.load_async.begin((obj, res) => {
	        try {
	            loader.load_async.end(res);
        	} catch (ThreadError e) {
        	    stderr.printf("%s\n", e.message);
        	    assert(false);
        	}
        	show_spinner(false);
            this.tree_view.set_model(loader.store);
    	});
    }
    
    public static int run(string[] args) {
    	Gtk.init(ref args);
    	var window = new AugeditApplication();
	    window.destroy.connect(Gtk.main_quit);
        window.show_all();
        Idle.add(() => {
            log(null, LogLevelFlags.LEVEL_DEBUG, "start loading augeas...\n");
            window.load_augeas();
            return false;
        });
	    Gtk.main();
    	return 0;
    }
}
