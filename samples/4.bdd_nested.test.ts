// https://deno.land/std@0.163.0/testing/bdd_examples/user_nested_test.ts
import { assertEquals, assertStrictEquals, assertThrows } from "@std/assert";
import { afterEach, beforeEach, describe, it, test } from "@std/testing/bdd";
import { User } from "./bdd_example/user.ts";

describe("User", () => {
  it.ignore("users initially empty", () => {
    assertEquals(User.users.size, 0);
  });

  test(function constructor() {
    try {
      const user = new User("Kyle");
      assertEquals(user.name, "Kyle");
      assertStrictEquals(User.users.get("Kyle"), user);
    } finally {
      User.users.clear();
    }
  });

  describe("age", function () {
    let user: User;

    beforeEach(() => {
      user = new User("Kyle");
    });

    afterEach(() => {
      User.users.clear();
    });

    it({ name: "getAge" }, function () {
      assertThrows(() => user.getAge(), Error, "Age unknown");
      user.age = 18;
      assertEquals(user.getAge(), 18);
    });

    test({
      name: "setAge",
      fn: () => {
        user.setAge(18);
        assertEquals(user.getAge(), 18);
      },
    });
  });
});
