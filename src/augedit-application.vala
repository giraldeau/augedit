/* Copyright 2012 Francis Giraldeau
 *
 * This software is licensed under the GNU General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

using Gtk;
using GLib;

public class AugeditApplication : Window {

    public const string VERSION = Config.PACKAGE_VERSION;
    public const string PRGNAME = Config.PACKAGE_NAME;

    private TreeView tree_view;
    private AugeditLoader loader;
    private Box container;
    private ScrolledWindow scroll;
    private Spinner spinner;
    private Table spinner_widget;
    private TextView text_view;
    private Box vbox;
    private Box hbox;

    static string aug_root;
    static bool version = false;

    const OptionEntry[] options = {
        { "root", 0, 0, OptionArg.FILENAME, ref aug_root, N_("Use ROOT as the root of the filesystem"), null },
        { "version", 0, 0, OptionArg.NONE, ref version, N_("Display program version"), null },
        { null }
    };

    public AugeditApplication() {
        AugeditApplication.with_args(null);
    }

    public AugeditApplication.with_args(string[]? args) {
        Intl.bindtextdomain(Config.GETTEXT_PACKAGE, Config.PACKAGE_LOCALEDIR);
        Intl.bind_textdomain_codeset(Config.GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain(Config.GETTEXT_PACKAGE);

        parse_arguments(args);
        this.title = _("Augeas configuration editor\n");
        this.window_position = WindowPosition.CENTER;
        set_default_size(600, 500);

        var toolbar = new Toolbar();
        toolbar.get_style_context().add_class(STYLE_CLASS_PRIMARY_TOOLBAR);

        this.tree_view = new TreeView();
        this.tree_view.insert_column_with_attributes(-1, "Key",
            new CellRendererText(), "text", AugeditLoader.Columns.KEY, null);
        this.tree_view.insert_column_with_attributes(-1, "Value",
            new CellRendererText(), "text", AugeditLoader.Columns.VALUE, null);
        this.tree_view.cursor_changed.connect(() => {
            update_tags();
        });

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

        text_view = new TextView();
        text_view.editable = false;
        text_view.cursor_visible = false;
        text_view.set_sensitive(false);

        container = new Box(Orientation.VERTICAL, 0);
        hbox = new Box(Orientation.HORIZONTAL, 0);
        hbox.set_homogeneous(true);
        hbox.pack_start(container, true, true, 0);
        hbox.pack_start(text_view, true, true, 0);

        vbox = new Box(Orientation.VERTICAL, 0);
        vbox.pack_start(toolbar, false, true, 0);
        vbox.pack_start(hbox, true, true, 0);
        add(vbox);
    }

    public void show_spinner(bool enable) {
        bool is_enabled = spinner_widget.get_parent() != null;
        if (enable && !is_enabled) {
            if (scroll.get_parent() != null)
                container.remove(scroll);
            container.pack_start(spinner_widget, true, false, 0);
            spinner_widget.show_all();
            spinner.start();
        }
        if (!enable && is_enabled) {
            container.remove(spinner_widget);
            container.pack_start(scroll, true, true, 0);
            scroll.show_all();
            spinner.stop();
        }
    }

    public void update_tags() {
        TreeModel model;
        TreeIter iter, parent;
        var builder = new StringBuilder ();
        string last = null, path = null;
        bool ok = true;
        tree_view.get_selection().get_selected(out model, out iter);
        if (!loader.store.iter_is_valid(iter))
            return;
        /*
        // walk the tree until the root and build the path of the node
        while(ok) {
            GLib.Value key;
            model.get_value(iter, AugeditLoader.Columns.KEY, out key);
            ok = model.iter_parent(out parent, iter);
            iter = parent;
            last = key.get_string();
            builder.prepend(last);
            builder.prepend("/");
        }
        if (last == null || last != "files")
            return;
        path = builder.str;
        path = path["/files".length:path.length];
        */
        //loader.augeas.span()

        if (path != null)
            load_text_file(path);
    }

    private void load_text_file(string path) {
        string text = "";
        try {
            FileUtils.get_contents(path, out text);
        } catch (Error e) {
            stdout.printf("Error reading file%s\n", e.message);
        }
        text_view.buffer.text = text;
    }

    private int parse_arguments(string[] args) {
        var context = new OptionContext("");
        context.set_help_enabled(true);
        context.add_main_entries(options, null);
        context.add_group(Gtk.get_option_group(false));
        try {
            context.parse(ref args);
        } catch (GLib.Error error) {
            GLib.error(_("Failed to parse command line: %s"), error.message);
        }
        if (version) {
            stdout.printf("%s %s\n", PRGNAME, VERSION);
            return 1;
        }
        return 0;
    }

    public void load_augeas() {
        show_spinner(true);
        this.loader = new AugeditLoader.with_args(aug_root, null);
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
        var window = new AugeditApplication.with_args(args);
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
