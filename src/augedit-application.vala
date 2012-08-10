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
    private Box vbox;
    
    public AugeditApplication() {
        this.title = _("Hello World!\n");
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
        spinner.start();
        
        container = new Box(Orientation.VERTICAL, 0);
        container.pack_start(spinner, true, false, 0);
        
        vbox = new Box(Orientation.VERTICAL, 0);
        vbox.pack_start(toolbar, false, true, 0);
        vbox.pack_start(container, true, true, 0);
        add(vbox);

        // FIXME: need a little spindle to wait for few seconds
        loader = new AugeditLoader();
        try {
            loader.load();
        } catch (Error e) {
            stderr.printf("%s\n", e.message);
        }
        container.remove(spinner);
        container.pack_start(scroll, true, true, 0);
        this.tree_view.set_model(loader.store);
    }
}
