/*
 * Copyright (C) 2011 Francis Giraldeau <francis.giraldeau@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this library; see the file COPYING.LIB.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 */

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <glib.h>
#include <glib/gi18n.h>
#include <gtk/gtk.h>

#include <stdlib.h>

static void display_version ()
{
  g_print (_("%s - Version %s\n"), g_get_application_name (), PACKAGE_VERSION);
}

int main (int argc, char **argv)
{
  GdkGeometry geometry;
  GtkWidget *window;

  display_version();
  gtk_init (&argc, &argv);
  g_set_application_name (_("Augedit configuration editor"));

  window = gtk_window_new (GTK_WINDOW_TOPLEVEL);

  gtk_window_set_geometry_hints (GTK_WINDOW(window), GTK_WIDGET(window),
      &geometry,  GDK_HINT_MIN_SIZE);

  g_signal_connect (window, "delete-event", gtk_main_quit, NULL);
  gtk_widget_show (window);
  gtk_main ();
  return 0;
}
