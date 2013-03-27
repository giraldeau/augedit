/* Copyright 2012 Francis Giraldeau
 *
 * This software is licensed under the GNU General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

using Gtk;
using GLib;
using Gee;
using Gdk;
using Augeas;

public class AugeditApplication : Gtk.Window {

    public const string SEP = "/";
    public const string VERSION = Config.PACKAGE_VERSION;
    public const string PRGNAME = Config.PACKAGE_NAME;


    private Color color_label;
    private Color color_value;
    private Color color_span;
    private TreeView tree_view;
    private AugeditLoader loader;
    private Box container;
    private ScrolledWindow scroll_tree;
    private ScrolledWindow scroll_text;
    private Spinner spinner;
    private Table spinner_widget;
    private TextView text_view;
    private Toolbar toolbar;
    private ToolButton save_button;
    private Box vbox;
    private Box hbox;
    private string current_file = "";

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

        createToolbar();
        createTreeView();
        createTextView();
        createTags();

        spinner = new Spinner();
        var spinner_label = new Label(_("Loading..."));
        var box = new Box(Orientation.HORIZONTAL, 5);
        box.pack_start(spinner, true, true, 5);
        box.pack_start(spinner_label, true, true, 5);
        spinner_widget = new Table(3, 3, true);
        spinner_widget.attach(box, 1, 2, 1, 2, AttachOptions.EXPAND, AttachOptions.FILL, 3, 3);

        hbox = new Box(Orientation.HORIZONTAL, 0);
        hbox.set_homogeneous(true);
        hbox.pack_start(scroll_tree, true, true, 0);
        hbox.pack_start(scroll_text, true, true, 0);

        // the container's children toggles between hbox and spinner
        container = new Box(Orientation.VERTICAL, 0);
        show_spinner(true);

        vbox = new Box(Orientation.VERTICAL, 0);
        vbox.pack_start(toolbar, false, true, 0);
        vbox.pack_start(container, true, true, 0);
        add(vbox);
    }

    private void createTags() {
        Gdk.Color.parse("#ff0000", out color_label);
        Gdk.Color.parse("#00ff00", out color_value);
        Gdk.Color.parse("#0000ff", out color_span);
        setup_tag("label", color_label);
        setup_tag("value", color_value);
        setup_tag("span", color_span);
    }

    private void createToolbar() {
        toolbar = new Toolbar();
        toolbar.get_style_context().add_class(STYLE_CLASS_PRIMARY_TOOLBAR);
        save_button = new ToolButton.from_stock(Stock.SAVE);
        toolbar.add(save_button);
    }

    private void createTreeView() {
        tree_view = new TreeView();
        tree_view.insert_column_with_attributes(-1, "Key",
            new CellRendererText(), "text", AugeditLoader.Columns.KEY, null);
        tree_view.insert_column_with_attributes(-1, "Value",
            new CellRendererText(), "text", AugeditLoader.Columns.VALUE, null);
        tree_view.cursor_changed.connect(() => {
            update_text_view();
        });

        scroll_tree = new ScrolledWindow(null, null);
        scroll_tree.set_policy(PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
        scroll_tree.add(tree_view);
    }

    private void createTextView() {
        text_view = new TextView();
        text_view.editable = false;
        text_view.cursor_visible = false;
        text_view.set_sensitive(false);
        text_view.set_wrap_mode(Gtk.WrapMode.WORD);

        scroll_text = new ScrolledWindow(null, null);
        scroll_text.set_policy(PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
        scroll_text.add(text_view);
    }

    public void show_spinner(bool enable) {
        empty_container(container);
        if (enable) {
            container.pack_start(spinner_widget, true, false, 0);
            spinner_widget.show_all();
            spinner.start();
        } else {
            container.pack_start(hbox, true, true, 0);
            hbox.show_all();
            spinner.stop();
        }
    }

    public void empty_container(Container container) {
        var children = container.get_children();
        foreach(Widget child in children) {
            container.remove(child);
        }
    }

    public void update_text_view() {
        LinkedList<string> list = get_selected_path(tree_view);
        string selected_path = join_path(list);
        if (list.size <= 1)
            return;
        // remove heading "files"
        list.remove_at(0);
        bool found = false;
        var builder = new StringBuilder();
        foreach (var item in list) {
            builder.append(SEP);
            builder.append(item);
            found = FileUtils.test(builder.str,
                        FileTest.IS_REGULAR | FileTest.IS_SYMLINK);
            if (found)
                break;
        }
        if (found) {
            // only reload if the file changes
            set_current_file(builder.str);
            update_highlight(selected_path);
        } else {
            set_current_file("");
        }
    }

    public void set_current_file(string file) {
        if (current_file != file) {
            load_text_file(file);
        }
        current_file = file;
    }

    public void update_highlight(string path) {
        var span = new AugSpan();
        span.fetch(loader.get_augeas(), path);
        //stdout.printf("%s %s\n", path, span.to_string());
        var buf = text_view.get_buffer();

        // clear tags
        TextIter start;
        TextIter end;
        buf.get_iter_at_offset(out start, 0);
        buf.get_iter_at_offset(out end, buf.get_char_count());
        buf.remove_all_tags(start, end);
        highlight_text("span", span.span_start, span.span_end);
        highlight_text("label", span.label_start, span.label_end);
        highlight_text("value", span.value_start, span.value_end);

    }

    public void highlight_text(string name, uint start, uint end) {
        TextIter start_iter;
        TextIter end_iter;
        var buf = text_view.get_buffer();
        TextTag s = lookup_tag(name);
        buf.get_iter_at_offset(out start_iter, (int) start);
        buf.get_iter_at_offset(out end_iter, (int) end);
        buf.apply_tag(s, start_iter, end_iter);
    }

    public void setup_tag(string name, Gdk.Color color) {
        var buf = text_view.get_buffer();
        var tbl = buf.get_tag_table();
        TextTag tag = tbl.lookup(name);
        if (tag == null) {
            tag = new TextTag(name);
            tag.set_property("background-gdk", color);
            tbl.add(tag);
        }
    }

    public TextTag? lookup_tag(string name) {
        var buf = text_view.get_buffer();
        var tbl = buf.get_tag_table();
        return tbl.lookup(name);
    }

    /*
     * Convert path element list to path string
     */
    private string join_path(LinkedList<string> list) {
        var builder = new StringBuilder();
        foreach (var item in list) {
            builder.append(SEP);
            builder.append(item);
        }
        return builder.str;
    }

    /*
     * Retrieve the list of path elements of the selected node in the tree.
     */
    private LinkedList<string> get_selected_path(TreeView tree) {
        TreeModel model;
        TreeIter iter, parent;
        string label = null;
        bool ok = true;
        LinkedList<string> list = new LinkedList<string>();

        tree.get_selection().get_selected(out model, out iter);
        if (!loader.store.iter_is_valid(iter))
            return list;

        while(ok) {
            GLib.Value key;
            model.get_value(iter, AugeditLoader.Columns.KEY, out key);
            ok = model.iter_parent(out parent, iter);
            iter = parent;
            label = key.get_string();
            list.insert(0, label);
        }
        return list;
    }

    private void load_text_file(string path) {
        string text = "";
        if (path.length > 0) {
            try {
                FileUtils.get_contents(path, out text);
            } catch (Error e) {
                stdout.printf("Error reading file%s\n", e.message);
            }
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
        loader = new AugeditLoader.with_args(aug_root, null);
        loader.load_async.begin((obj, res) => {
            try {
                loader.load_async.end(res);
            } catch (ThreadError e) {
                stderr.printf("%s\n", e.message);
                assert(false);
            }
            show_spinner(false);
            tree_view.set_model(loader.store);
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
