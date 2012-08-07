/* Copyright 2012 Francis Giraldeau
 *
 * This software is licensed under the GNU General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution. 
 */

int main(string[] args) {
	Gtk.init(ref args);
	
    var window = new AugeditApplication();
    window.destroy.connect(Gtk.main_quit);
    window.show_all();
    
	Gtk.main();
	return 0;
}
