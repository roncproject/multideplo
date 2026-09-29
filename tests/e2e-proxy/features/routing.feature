Feature: Nginx reverse proxy routing
  The deployed container fronts the game with Nginx (see nginx.conf).
  These scenarios test the routing itself, against the real built
  container - not the bare jar the way the app's own e2e suite does.

  Scenario: Root path serves the RuhRohgue game
    When I open "/"
    Then the response status is 200
    And the page shows the RuhRohgue game

  Scenario: Explicit /app1/ alias serves the same game
    When I open "/app1/"
    Then the response status is 200
    And the page shows the RuhRohgue game

  @known-limitation
  Scenario Outline: Unimplemented routes fail loudly, not silently
    # app2.jar is a CI placeholder (see deploy.yml) - nothing listens on
    # its port, so Nginx must bad-gateway rather than hang or leak a
    # default page. If this starts failing, app2 is real now - update
    # this scenario instead of muting it.
    When I request "<path>"
    Then the response status is 502

    Examples:
      | path   |
      | /app2/ |
      | /api/  |
