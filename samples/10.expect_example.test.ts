import { expect, fn } from "@std/expect";

Deno.test("basic sum", () => {
  expect(1 + 2).toBe(3);
});

Deno.test("object equality", () => {
  const obj1 = { a: 1, b: 2 };
  const obj2 = { a: 1, b: 2 };
  expect(obj1).toEqual(obj2);
});

Deno.test("mock funtion", () => {
  const mockFn = fn(
    (a: number, b: number) => a + b,
    (a: number, b: number) => a - b,
  );

  const result1 = mockFn(1, 2);
  expect(result1).toBe(3);
  expect(mockFn).toHaveBeenCalledWith(1, 2);
  expect(mockFn).toHaveBeenCalledTimes(1);

  const result2 = mockFn(3, 2);
  expect(result2).toEqual(1);
  expect(mockFn).toHaveBeenCalledWith(3, 2);
  expect(mockFn).toHaveBeenCalledTimes(2);
});
