"""User interface for Augeas

Augeas is a library for programmatically editing configuration files. 
Augeas parses configuration files into a tree structure, which it exposes 
through its public API. Changes made through the API are written back to 
the initially read files.
"""

#
# Copyright (C) 2010 Francis Giraldeau <francis.giraldeau@usherbrooke.ca>
# Copyright (C) 2009 David Malcolm <dmalcolm@redhat.com>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#

__author__ = "Francis Giraldeau <francis.giraldeau@usherbrooke.ca>"
__credits__ = """David Malcolm <dmalcolm@redhat.com> - Initial prototype"""

from augeas import Augeas
import pygtk
pygtk.require('2.0')
import gtk
import pango
import os

def add_with_scrolling(parent, child):
    sw = gtk.ScrolledWindow()
    sw.add(child)
    parent.add(sw)

class AugeasEditor:
    def delete_event(self, widget, event, data=None):
        gtk.main_quit()
        return False

    def populate_tree_store(self, path, parent_iter):
        iter = self.tree_store.append(parent_iter, [path, self.aug.get(path)])
        if path == "/":
            path = ""
        try:
            child_paths = self.aug.match(path+'/*')
        except RuntimeError:
            return        
        for path in child_paths:
            self.populate_tree_store(path, iter),

    def setup_tags(self, spec):
        buf = self.textview.get_buffer()
        tbl = buf.get_tag_table()
        
        tag = tbl.lookup("value")
        if not tag:
            tag = gtk.TextTag("value")
            tag.set_property("background-gdk", gtk.gdk.Color(65535,54400,42000,0)) 
            tbl.add(tag)

        tag = tbl.lookup("label")
        if not tag:
            tag = gtk.TextTag("label")
            tag.set_property("background-gdk", gtk.gdk.Color(65535,42000,54400,1)) 
            tbl.add(tag)

    def __init__(self):
        self.aug = Augeas()
        self.cur_file = ""
        
        self.window = gtk.Window(gtk.WINDOW_TOPLEVEL)
        self.window.set_title("Augeas viewer")

        self.window.set_size_request(500, 400)

        self.window.connect("delete_event", self.delete_event)

        self.tree_store = gtk.TreeStore(str, str)
        self.populate_tree_store('/', None)

        self.treeview = gtk.TreeView(self.tree_store)

        for (i, columnName) in enumerate(['Path', 'Value']):
            column = gtk.TreeViewColumn(columnName)

            self.treeview.append_column(column)

            cr = gtk.CellRendererText()
            column.pack_start(cr, True)

            column.add_attribute(cr, 'text', i)
            column.set_sort_column_id(i)

        self.treeview.set_search_column(0)            

        self.textview = gtk.TextView()
        self.setup_tags(None)        
        hbox = gtk.HBox()
        add_with_scrolling(hbox, self.treeview)
        add_with_scrolling(hbox, self.textview)
        self.window.add(hbox)

        self.treeview.get_selection().connect('changed', self.on_selection_changed, self)

        self.window.show_all()

    def on_selection_changed(self, selection, foo):
        (model, iter) = selection.get_selected()
        if (iter == None):
            return
        path = model.get_value(iter, 0)
        if not path.startswith('/files/'):
            return

        try:
            res = self.aug.info(path)
        except ValueError:
            return
            
        if os.path.isfile(res["filename"]) and res["filename"] != self.cur_file:
            print "set content to %s" % (res["filename"])
            content = open(res["filename"]).read()
            buf = self.textview.get_buffer()
            buf.set_text(content)
            self.cur_file = res["filename"]
        
        buf = self.textview.get_buffer()
        tbl = buf.get_tag_table()
        
        label_tag = tbl.lookup("label")
        value_tag = tbl.lookup("value")
        
        buf.remove_all_tags(buf.get_iter_at_offset(0), buf.get_iter_at_offset(buf.get_char_count()))
        print "apply tag"
        buf.apply_tag(label_tag, buf.get_iter_at_offset(res["label_start"]),
                   buf.get_iter_at_offset(res["label_end"]))

        buf.apply_tag(value_tag, buf.get_iter_at_offset(res["value_start"]),
                   buf.get_iter_at_offset(res["value_end"]))
        offset = res["label_start"]
        if (res["value_start"] > offset):
            offset = res["value_start"] 
        self.textview.scroll_to_iter(buf.get_iter_at_offset(offset), 0.2)
        
if __name__ == "__main__":
    app = AugeasEditor()
    gtk.main()
