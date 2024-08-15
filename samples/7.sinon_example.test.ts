// Copyright 2018-2022 the Deno authors. All rights reserved. MIT license.

/**
 * An example of using [Sinon.js](https://sinonjs.org/) with `Deno.test()`.
 *
 * Run this example with:
 *
 * ```shellsession
 * $ deno test ./testing/sinon_example.ts
 * ```
 *
 * @module
 */

// @ts-types="npm:@types/sinon"
import sinon from "npm:sinon@9.2.4";
// @ts-types="npm:@types/chai/index.d.ts"
import * as chai from "npm:chai@5.1.1";

Deno.test("stubbed callback", () => {
  const callback = sinon.stub();
  callback.withArgs(42).returns(1);
  callback.withArgs(1).throws(new Error("test-error"));

  chai.assert.isUndefined(callback()); // No return value, no exception
  chai.assert.equal(callback(42), 1); // Returns 1
  chai.assert.equal(callback.withArgs(42).callCount, 1); // Use withArgs in assertion
  chai.assert.throws(() => {
    callback(1);
  }, "test-error"); // Throws Error("test-error")
});
