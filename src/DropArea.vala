namespace Resizer {
  public class DropArea : Gtk.Overlay {

    private Gtk.Image image;
    private Gtk.Image image2;
    private Gtk.Label drag_label;

    construct {
      image = new Gtk.Image ();
      image.get_style_context ().add_class ("card");
      image.hexpand = true;
      image.width_request = 300;
      image.height_request = 200;
      image.margin = 6;

      image2 = new Gtk.Image ();
      image2.get_style_context ().add_class ("card");
      image2.margin = 6;
      image2.margin_left = 6+6;
      image2.margin_top = 6;
      image2.visible = false;

      drag_label = new Gtk.Label (_("Drop Image(s) Here"));
      drag_label.justify = Gtk.Justification.CENTER;

      var drag_label_style_context = drag_label.get_style_context ();
      drag_label_style_context.add_class ("h2");
      drag_label_style_context.add_class (Gtk.STYLE_CLASS_DIM_LABEL);

      var images = new Gtk.Fixed();
      images.valign = Gtk.Align.CENTER;
      images.halign = Gtk.Align.CENTER;
      images.put (image2, 0, 0);
      images.put (image, 0, 0);
      this.add(images);
      this.add_overlay (drag_label);
    }
    public void show_preview(File[] files) {
      drag_label.visible = false;
      drag_label.no_show_all = true;

      var file = files[0];
      var pixbuf = new Gdk.Pixbuf.from_file_at_scale (
        file.get_path (),
        300,
        500,
        true
      );
      image.set_from_pixbuf (pixbuf);
      image.height_request = pixbuf.height;
      image.width_request = pixbuf.width;

      if (files.length > 1) {
        var file2 = files[1];
        stdout.printf ("second image: %s\n", file2.get_path ());
        var pixbuf2 = new Gdk.Pixbuf.from_file_at_scale (
          file2.get_path (),
          300,
          500,
          true
        );
        image2.set_from_pixbuf (pixbuf2);
        image2.visible = true;

        image.margin_top = 6+6;
      } else {
        image2.visible = false;

        image.margin_top = 6;
      }
    }
  }
}
