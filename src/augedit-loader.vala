/* Copyright 2012 Francis Giraldeau
 *
 * This software is licensed under the GNU General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution. 
 */

using Gtk;
using Augeas;

public errordomain AugeditError {
    NO_ERROR,
    LOAD_FAILED
}

public class AugeditLoader : Object {

    public enum Columns {
        KEY = 0,
        VALUE
    }
    
    public TreeStore store { get; private set; }
    private Augeas.Tree augeas;
    
    public AugeditLoader() {
        this.with_args(null, null);
    }

    public AugeditLoader.with_args(string? root, string? loadpath) {
        augeas = new Augeas.Tree(root, loadpath, InitFlags.NO_LOAD);
        store = new TreeStore(2, typeof(string), typeof(string));
    }
    
    public void load() throws AugeditError {
        // FIXME: spawn a thread for async loading
        if (augeas.load() < 0) {
            throw new AugeditError.LOAD_FAILED("Failed to load augeas tree");
        }
    }
    
    public unowned Augeas.Tree get_augeas() {
        return augeas;
    }
}

