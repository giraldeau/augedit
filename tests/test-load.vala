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
	public static void test_load_simple() {
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
	public static void test_load_root() {
	    string root = get_root();
	    var loader = new AugeditLoader.with_args(root, null);
	    try {
    	    loader.load();
    	} catch (AugeditError e) { }
    	int act = 0;
    	loader.store.foreach((a, b, c) => {
    	    act++;
    	    return false;
    	});
    	string[]? res = loader.get_augeas().match("//*");
    	assert(res.length == act);
	}
	
	public static void main (string[] args) {
		Test.init (ref args);
		Test.add_func ("/augedit/load/simple", test_load_simple);
		Test.add_func ("/augedit/load/root", test_load_root);
		Test.run ();
	}
}
