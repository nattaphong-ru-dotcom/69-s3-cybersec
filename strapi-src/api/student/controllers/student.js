'use strict';

/**
 * student controller
 */

const { createCoreController } = require('@strapi/strapi').factories;
const { errors } = require('@strapi/utils');

const INT4_MAX = 2147483647;

const isValidId = (id) => /^[1-9]\d*$/.test(id) && Number(id) <= INT4_MAX;

const assertValidId = (ctx) => {
  const { id } = ctx.params;
  if (!isValidId(String(id))) {
    throw new errors.NotFoundError(
      `Invalid id "${id}" - id must be an integer between 1 and ${INT4_MAX}`
    );
  }
};

const guardId = (handler) =>
  async function guarded(ctx) {
    assertValidId(ctx);
    return handler.call(this, ctx);
  };

const createStudentController = createCoreController('api::student.student');

module.exports = ({ strapi }) => {
  const controller = createStudentController({ strapi });

  return Object.assign(controller, {
    findOne: guardId(controller.findOne),
    update: guardId(controller.update),
    delete: guardId(controller.delete),
  });
};
