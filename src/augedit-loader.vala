/* Copyright 2012 Francis Giraldeau
 *
 * This software is licensed under the GNU General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution. 
 */

using Gtk;
using Augeas;

public class AugeasLoader : Object {

    public enum Columns {
        KEY = 0,
        VALUE
    }
    
    public TreeStore store { get; private set; }
    private Augeas.Tree augeas;
    
    public AugeasLoader() {
        augeas = new Augeas.Tree(null, null, InitFlags.NO_LOAD);
        store = new TreeStore(2, typeof(string), typeof(string));
    }
    
    public void load() {
        // FIXME: spawn a thread for async loading
//        augeas.load();
        TreeIter iter;
        store.append(out iter, null);
	    store.set(iter, Columns.KEY, "test 1", 
	                    Columns.VALUE, "test 2", -1);
        store.append(out iter, null);
	    store.set(iter, Columns.KEY, "test 3", 
	                    Columns.VALUE, "test 4", -1);
	    /*

        store.clear();
        string[] keys = augeas.match("/*");
        foreach(string key in keys) {
            string k = key[1:key.length];
            string? val;
            augeas.get("/" + k, out val);
            string value = val != null ? val : "";
            stdout.printf("{ \"%s\" = \"%s\"\n", k, value);
            
            store.append(out iter, null);
            store.set(iter,
                Columns.KEY, k,
                Columns.VALUE, val , -1);
        }
        */
    }
    
    
    
    public unowned Augeas.Tree get_augeas() {
        return augeas;
    }
}

