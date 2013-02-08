/*
 * Test simple augload to check the environment
 */
using GLib;
using Gtk;
using Augeas;

static const string srcdir_var = "abs_top_srcdir";

errordomain Error {
     ENV_NOT_SET
}

public class AugeditLoadTest: Object {

    /*
     * returns the path of input files
     */
    public static string? get_root() {
        string? abs_top_srcdir = Environment.get_variable(srcdir_var);
        if (abs_top_srcdir == null) {
            stderr.printf("Variable " + srcdir_var + " must be set");
            return null;
        }
        string test_root = Path.build_path("/", abs_top_srcdir, "tests", "root");
	    return test_root;
    }

    /*
     * Just try to build the object and load the tree
     */
	public static void test_load_sync() {
	    string root = get_root();
	    var loader = new AugeditLoader.with_args(root, null);
	    bool has_error = false;
	    try {
    	    loader.load();
    	} catch (AugeditError e) {
    	    has_error = true;
    	    stderr.printf("%s\n", e.message);
    	}
    	assert(has_error == false);
	}

	/*
	 * The number of augeas and store nodes must match
	 */
	public static void test_load_async() {
	    string root = get_root();
	    var loop = new MainLoop();
	    var loader = new AugeditLoader.with_args(root, null);
	    loader.load_async.begin((obj, res) => {
	        try {
	            loader.load_async.end(res);
        	} catch (ThreadError e) {
        	    stderr.printf("%s\n", e.message);
        	    assert(false);
        	}
        	loop.quit();
    	});
    	loop.run(); // wait until loaded
    	int act = 0;
    	loader.store.foreach((a, b, c) => {
    	    act++;
    	    return false;
    	});
    	string[]? res = loader.get_augeas().match("//*");
    	assert(res.length == act);
	}

	/*
	 * Test correct behavior of span
	 */
	public static void test_span() {
	    string path = "/files/etc/hosts/1/ipaddr";
        string root = get_root();
        var augeas = new Augeas.Tree(root, null, InitFlags.NO_LOAD | InitFlags.ENABLE_SPAN);
        augeas.load();
        var span = new AugSpan();
        span.fetch(augeas, "/files/etc/hosts/1/ipaddr");
        assert("hosts" in span.filename);
        assert(span.label_start == 0);
        assert(span.label_end   == 0);
        assert(span.value_start > 0);
        assert(span.value_end   > 0);
        assert(span.span_start  > 0);
        assert(span.span_end    > 0);
	}

	public static void main (string[] args) {
		Test.init (ref args);
		Test.add_func ("/augedit/load/sync", test_load_sync);
		Test.add_func ("/augedit/load/async", test_load_async);
		Test.add_func ("/augedit/lib/span", test_span);
		Test.run ();

	}
}
