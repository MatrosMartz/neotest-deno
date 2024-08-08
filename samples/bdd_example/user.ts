// https://deno.land/std@0.207.0/testing/bdd_examples/user.ts
export class User {
  static users: Map<string, User> = new Map();
  age?: number;

  constructor(public name: string) {
    if (User.users.has(name)) {
      throw new Deno.errors.AlreadyExists(`User ${name} already exists`);
    }
    User.users.set(name, this);
  }

  getAge(): number {
    if (!this.age) {
      throw new Error("Age unknown");
    }
    return this.age;
  }

  setAge(age: number) {
    this.age = age;
  }
}
