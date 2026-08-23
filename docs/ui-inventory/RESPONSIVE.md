# Responsive UI Inventory

- Compact: `< 600` effective px (NavigationBar + TopAppBar)
- Medium: `600–839` effective px (NavigationRail)
- Expanded: `840–1199` effective px (expanded NavigationRail)
- Large: `1200–1599` effective px (permanent NavigationDrawer)
- Extra-large: `>= 1600` effective px (wide permanent NavigationDrawer)

`MeoNavigationSuite` keeps navigation geometry stable while a window is being
resized, then uses the shared motion tokens to settle between the five modes.
Compact navigation renders at most five destinations; longer models expose the
remaining destinations through its modal overflow drawer.
