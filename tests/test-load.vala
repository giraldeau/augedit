/*
 * Test simple augload to check the environment
 */
using GLib;
using Gtk;
using Augeas;

public class AugeditLoadTest: Object {
	public static void test_store () {
	    int act = 0;
	    var store = new TreeStore(2, typeof(string), typeof(string));
	    TreeIter iter;
	    store.append(out iter, null);
	    store.set(iter, AugeasLoader.Columns.KEY, "test 1", -1);
	    
	    store.foreach((model, path, iter) => {
	        string str;
	        model.get(iter, AugeasLoader.Columns.KEY, out str, -1);
	        act++;
	        stdout.printf("%s\n", str);
	        return false;
	    });
    	/*
	    var aug2 = new Augeas.Tree();
	    string[] res = aug2.match("//*");
	    stdout.printf("%d %d\n", act, res.length);
	    */
	}
	
	public static void test_load() {
	    var loader = new AugeasLoader();
	    loader.load();
	}
	
	public static void main (string[] args) {
		Test.init (ref args);
		Test.add_func ("/aug/vala/match", test_store);
		Test.add_func ("/aug/vala/match", test_load);
		Test.run ();
	}
}
