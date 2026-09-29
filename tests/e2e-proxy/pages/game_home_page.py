class GameHomePage:
    """Wraps the RuhRohgue index page (see ruhrohgue's templates/index.html)."""

    def __init__(self, page):
        self.page = page

    def is_loaded(self) -> bool:
        titlebar = self.page.locator("#titlebar")
        grid = self.page.locator("#dungeon-grid")
        return (
            titlebar.count() > 0
            and "RuhRohgue" in titlebar.inner_text()
            and grid.count() > 0
        )
