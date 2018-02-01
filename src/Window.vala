/*
* Copyright (c) 2011-2018 Peter Uithoven (https://peteruithoven.nl)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Peter Uithoven <peter@peteruithoven.nl>
*/

namespace Resizer {
  public class Window : Gtk.Dialog {
  // public class Window : Gtk.ApplicationWindow {

    private Settings settings = new Settings (Constants.PROJECT_NAME);
    private Gtk.SpinButton width_entry;
    private Gtk.SpinButton height_entry;
    private Gtk.Widget cancel_btn;
    private Gtk.Widget resize_btn;
    private Gtk.Stack pages;

    public Window () {
      Object (border_width: 6,
              resizable: false);
    }
    construct {
      this.default_width = 200;
      this.title = _("Resizer");

      // Input page
      var label = new Gtk.Label (_("Resize image within:"));
      label.halign = Gtk.Align.START;

      var width_label = new Gtk.Label (_("Width:"));
      width_label.halign = Gtk.Align.START;

      width_entry = new Gtk.SpinButton.with_range (1, 10000, 1000);
      width_entry.hexpand = true;
      width_entry.set_activates_default (true);
      settings.bind ("width", width_entry, "value", GLib.SettingsBindFlags.DEFAULT);

      var height_label = new Gtk.Label (_("Height:"));
      height_label.halign = Gtk.Align.START;

      height_entry = new Gtk.SpinButton.with_range (1, 10000, 1000);
      height_entry.hexpand = true;
      height_entry.set_activates_default (true);
      settings.bind ("height", height_entry, "value", GLib.SettingsBindFlags.DEFAULT);

      var grid = new Gtk.Grid ();
      grid.column_spacing = 12;
      grid.row_spacing = 12;
      grid.margin = 6;
      grid.attach(label, 0, 0, 2, 1);
      grid.attach(width_label, 0, 1, 1, 1);
      grid.attach(width_entry, 1, 1, 1, 1);
      grid.attach(height_label, 0, 2, 1, 1);
      grid.attach(height_entry, 1, 2, 1, 1);
      grid.row_spacing = 6;

      // Gtk.Box content = get_content_area () as Gtk.Box;
      // content.add (grid);

      // Progress page
      var progress_page = new Gtk.Grid ();
      progress_page.margin = 6;

      Gtk.ProgressBar bar = new Gtk.ProgressBar ();
      bar.set_text ("Resizing");
      bar.set_show_text (true);
      GLib.Timeout.add (500, () => {
          // Get the current progress:
          // (0.0 -> 0%; 1.0 -> 100%)
          double progress = bar.get_fraction ();

          // Update the bar:
          progress = progress + 0.2;
          bar.set_fraction (progress);

          // Repeat until 100%
          // return progress < 1.0;
          if ( progress > 1.0 ) {
            bar.set_fraction (0.0);
          }
          return true;
          // return progress < 1.0;
      });
      progress_page.add (bar);

      // Pages
      pages = new Gtk.Stack ();
      pages.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
      pages.add_named (grid, "input");
      pages.add_named (progress_page, "progress");
      pages.set_visible_child_name ("input");
      get_content_area ().add (pages);

      GLib.Timeout.add (3000, () => {
        pages.set_visible_child_name ("progress");
        cancel_btn.sensitive = false;
        resize_btn.sensitive = false;
        return false;
      });

      cancel_btn = this.add_button(_("Cancel"), Gtk.ResponseType.CLOSE);
      resize_btn = this.add_button(_("Resize"), Gtk.ResponseType.APPLY);
      resize_btn.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
      resize_btn.can_default = true;
      this.set_default (resize_btn);

      response.connect (on_response);
      set_default_response(Gtk.ResponseType.APPLY);

      this.show_all ();
    }
    private void on_response (Gtk.Dialog source, int response_id) {
        switch (response_id) {
            case Gtk.ResponseType.APPLY:
                Resizer.maxWidth = width_entry.get_value_as_int ();
                Resizer.maxHeight = height_entry.get_value_as_int ();
                Resizer.create_resized_image();
                destroy ();
                break;
            case Gtk.ResponseType.CLOSE:
                destroy ();
                break;
            }
        }
    }
}
