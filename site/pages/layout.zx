
pub fn Layout(allocator: zx.Allocator, children: zx.Component) zx.Component {
  return (
    <html lang="en-US">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Nurul Huda (Apon)</title>
        <meta name="description" content="Staff Engineer at Voyage Mobile Inc. Tech enthusiast, Computer Science student at Green University of Bangladesh.">
        <meta name="author" content="Nurul Huda (Apon)">
        <meta property="og:title" content="Nurul Huda (Apon)">
        <meta property="og:description" content="Staff Engineer at Voyage Mobile Inc. Tech enthusiast, Computer Science student at Green University of Bangladesh.">
        <meta property="og:type" content="website">
        <meta property="og:url" content="https://nurulhudaapon.com">
        <meta name="twitter:card" content="summary">
        <meta name="twitter:title" content="Nurul Huda (Apon)">
        <meta name="twitter:description" content="Staff Engineer at Voyage Mobile Inc. Tech enthusiast, Computer Science student at Green University of Bangladesh.">
        <link rel="icon" href="https://nurulhudaapon.com/favicon.ico" sizes="32x32" type="image/x-icon">
      <style>
        {[CSS_STYLES:s]}
      </style>
      </head>

      <body>

          <Navbar />
          {(children)}

        <footer class="site-footer">
          <p class="copyright">© 2025 Nurul Huda (Apon).</p>
          <div class="social-links">
            <a href="mailto:nurulhudaapon@gmail.com">Email</a>
            <a href="https://github.com/nurulhudaapon">GitHub</a>
            <a href="https://x.com/nurulhudaapon">X</a>
            <a href="https://www.linkedin.com/in/nurulhudaapon">LinkedIn</a>
            <a href="https://youtube.com/@nurulhudaapon">YouTube</a>
          </div>
        </footer>
      </body>
    </html>
  );
}

const zx = @import("zx");
const Navbar = @import("component.zig").Navbar;
const NavbarProps = @import("component.zig").NavbarProps;

const CSS_STYLES = @embedFile("../assets/style.css");

