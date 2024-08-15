import { expect } from "npm:expect@29.7.0";
import * as mockFn from "npm:jest-mock@29.7.0";
import { expectTypeOf } from "npm:expect-type@0.9.2";

const operations = {
  sum(a: number, b: number): number {
    return a + b;
  },

  double(value: number): number {
    return this.sum(value, value);
  },
};

Deno.test("basic sum", () => {
  expect(operations.sum(1, 2)).toBe(3);
});

Deno.test("sum type check", async (t) => {
  await t.step("sum recives two numbers", () => {
    expectTypeOf(operations.sum).parameters.toEqualTypeOf<[number, number]>();
  });
  await t.step("sum return number", () => {
    expectTypeOf(operations.sum).returns.toBeNumber();
  });
});

Deno.test("object equality", () => {
  const obj1 = { a: 1, b: 2 };
  const obj2 = { a: 1, b: 2 };
  expect(obj1).toEqual(obj2);
});

Deno.test("double calls sum", () => {
  const spy = mockFn.spyOn(operations, "sum");
  operations.double(4);

  expect(spy).toBeCalledTimes(1);
  expect(spy).toBeCalledWith(4, 2);
  expect(spy).toReturnWith(8);
});
