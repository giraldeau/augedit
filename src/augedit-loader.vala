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
        this.augeas = new Augeas.Tree(root, loadpath, InitFlags.NO_LOAD);
        this.store = new TreeStore(2, typeof(string), typeof(string));
    }

    public void populate(string path, TreeIter? parent) {
        string? val, key;
        TreeIter iter;

        // Determine what is the key/value of this node
        key = Path.get_basename(path);
        augeas.get(path, out val);

        // create a new node in the store
        store.append(out iter, parent);
        store.set(iter, 0, key, 1, val, -1);

        // list children in the augeas tree
        string xpath = Path.build_path("/", path, "*");
        string[]? children = augeas.match(xpath);
        foreach (string child in children) {
            //stdout.printf("%s %s %s\n", child, key, val);
            populate(child, iter);
        }
    }

    public void load() {
        augeas.load();
        TreeIter? iter = null;
        populate("/augeas", iter);
        populate("/files", iter);
    }

    public async void load_async() throws ThreadError {
        SourceFunc callback = load_async.callback;
        stdout.printf("loading started");
        ThreadFunc<void*> run = () => {
            this.load();
            Idle.add((owned) callback);
            return null;
        };
        Thread.create<void*>(run, false);
        yield;
        return;
    }

    public unowned Augeas.Tree get_augeas() {
        return augeas;
    }
}

