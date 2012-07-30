/*
 * Test simple augload to check the environment
 */
using GLib;
using Augeas;

public class AugeditLoadTest: Object {
	public static void test_load () {
		var aug = new Augeas.Tree ();
		var res = aug.match ("/files/etc/passwd");
		assert (res != null);
		assert (res.length == 1);
	}
	public static void main (string[] args) {
		Test.init (ref args);
		Test.add_func ("/aug/vala/match", test_load);
		Test.run ();
	}
}