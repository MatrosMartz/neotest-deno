// https://deno.land/std@0.163.0/testing/bdd_examples/user_nested_test.ts
import { assertEquals, assertStrictEquals, assertThrows } from "@std/assert";
import { User } from "./bdd_example/user.ts";

Deno.test("User", async (t) => {
  await t.step("users initially empty", () => {
    assertEquals(User.users.size, 0);
  });

  await t.step(function constructor() {
    try {
      const user = new User("Kyle");
      assertEquals(user.name, "Kyle");
      assertStrictEquals(User.users.get("Kyle"), user);
    } finally {
      User.users.clear();
    }
  });

  await t.step("age", async function (t) {
    let user: User;

    user = new User("Kyle");
    await t.step({ name: "getAge" ,fn: function () {
      assertThrows(() => user.getAge(), Error, "Age unknown");
      user.age = 18;
      assertEquals(user.getAge(), 18);
    }});
    User.users.clear();
    
    user = new User("Kyle");
    await t.step({
      name: "setAge",
      fn: () => {
        user.setAge(18);
        assertEquals(user.getAge(), 18);
      },
    });
    User.users.clear();
  });
});
