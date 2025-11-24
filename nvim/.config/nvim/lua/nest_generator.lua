-- ~/.config/nvim/lua/generators/nest.lua

local M = {}

local function lower_first(s)
	return s:sub(1, 1):lower() .. s:sub(2)
end

local function kebab_case(s)
	local out = s:gsub("(%l)(%u)", "%1-%2")
	out = out:gsub("(%u)(%u%l)", "%1-%2")
	out = out:gsub("[_%s]+", "-")
	return out:lower()
end

local function pluralize(word)
	if not word or #word == 0 then
		return word
	end
	local last = word:sub(-1):lower()
	local before_last = #word > 1 and word:sub(-2, -2):lower() or ""
	if
		last == "y"
		and not (
			before_last == "a"
			or before_last == "e"
			or before_last == "i"
			or before_last == "o"
			or before_last == "u"
		)
	then
		return word:sub(1, -2) .. "ies"
	end
	if last == "s" or last == "x" or last == "z" or word:sub(-2):lower() == "sh" or word:sub(-2):lower() == "ch" then
		return word .. "es"
	end
	return word .. "s"
end

------------------------------------------------------
-- SERVICE GENERATOR
------------------------------------------------------
local function generate_service_content(serviceClassName, entityName)
	local entityLower = lower_first(entityName)
	local listQuery = "List" .. entityName .. "QueryDTO"
	local createDTO = "Create" .. entityName .. "RequestDTO"
	local updateDTO = "Update" .. entityName .. "RequestDTO"

	local tpl = string.format(
		[[
import { Injectable } from '@nestjs/common'

@Injectable()
export class %s {
  constructor(
    private connection: ConnectionService,
    private entityPatcher: EntityPatcherService
    ) {}

  findMany(ctx: RequestContext, filter: %s) {
    return this.connection.getRepository(ctx, %s).findAndCount({
      where: {},
      skip: (filter.take || 0) * (filter.page || 0),
      take: filter.take,
    })
  }

  async findOne(ctx: RequestContext, id: string) {
    const %s = await this.connection
      .getRepository(ctx, %s)
      .findOne({ where: { id } })

    if (!%s) {
      throw new EntityNotFoundException('%s')
    }

    return %s
  }

  create(ctx: RequestContext, data: %s) {
    const %s = new %s({})

    return this.connection.getRepository(ctx, %s).save(%s)
  }

  async update(ctx: RequestContext, id: string, data: %s) {
    const %s = await this.connection
      .getRepository(ctx, %s)
      .findOne({ where: { id } })

    if (!%s) {
      throw new EntityNotFoundException('%s')
    }

    this.entityPatcher.patch(%s, data)
    await this.connection.getRepository(ctx, %s).save(%s)

    return %s
  }

  async delete(ctx: RequestContext, id: string) {
    const %s = await this.connection
      .getRepository(ctx, %s)
      .findOne({ where: { id } })

    if (!%s) {
      throw new EntityNotFoundException('%s')
    }

    await this.connection.getRepository(ctx, %s).remove(%s)
  }
}
]],
		serviceClassName,
		listQuery,
		entityName,
		--
		entityLower,
		entityName,
		entityLower,
		entityName,
		entityLower,
		--
		createDTO,
		entityLower,
		entityName,
		entityName,
		entityLower,
		--
		updateDTO,
		entityLower,
		entityName,
		entityLower,
		entityName,
		entityLower,
		entityName,
		entityLower,
		entityLower,
		--
		entityLower,
		entityName,
		entityLower,
		entityName,
		entityName,
		entityLower
	)

	return vim.split(tpl, "\n")
end

function M.generate_service_into_buffer()
	vim.ui.input({ prompt = "Service class name (e.g. CandidateService): " }, function(serviceClassName)
		if not serviceClassName or serviceClassName == "" then
			vim.notify("Cancelled: missing service class name", vim.log.levels.WARN)
			return
		end
		vim.ui.input({ prompt = "Entity name (e.g. Candidate): " }, function(entityName)
			if not entityName or entityName == "" then
				vim.notify("Cancelled: missing entity name", vim.log.levels.WARN)
				return
			end

			local lines = generate_service_content(serviceClassName, entityName)
			vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
			vim.notify("✅ Inserted NestJS service for " .. entityName .. " in current buffer.")
		end)
	end)
end

------------------------------------------------------
-- CONTROLLER GENERATOR
------------------------------------------------------
local function generate_controller_content(controllerClassName, entityName)
	local entityLower = lower_first(entityName)
	local entityPlural = pluralize(entityName)
	local entityLowerPlural = lower_first(entityPlural)
	local serviceClass = entityName .. "Service"
	local serviceVar = lower_first(entityName) .. "Service"
	local listQuery = ("List%sQueryDTO"):format(entityName)
	local listResponse = ("List%sResponseDTO"):format(entityName)
	local getResponse = ("Get%sResponseDTO"):format(entityName)
	local updateDTO = ("Update%sRequestDTO"):format(entityName)

	local tpl = ([[
import { Controller, Get, Param, Query, Patch, Delete, Body } from '@nestjs/common'

@Controller('%s')
export class %s {
  constructor(private readonly %s: %s) {}

  @Get('')
  @Require(..)
  @ValidateResponse(%s)
  @Throws(NotAuthorizedException, ValidationException)
  async %s(@Ctx('user') ctx: UserRequestContext, @Query() query: %s): Promise<%s> {
    const [%s, total] = await this.%s.findMany(ctx, query)
    return {
      message: ctx.translate('success.entity_fetched', { args: { entity: '%s' } }),
      data: %s.map(c => ({ id: c.id })),
      pagination: getPaginationResponse(%s, total, query)
    }
  }

  @Get('/:id')
  @Require(..)
  @ValidateResponse(%s)
  @Throws(NotAuthorizedException, ValidationException)
  async %s(@Ctx('user') ctx: UserRequestContext, @Param() param: IdDTO): Promise<%s> {
    const %s = await this.%s.findOne(ctx, param.id)

    return {
      message: ctx.translate('success.entity_fetched', { args: { entity: '%s' } }),
      data: { id: %s.id }
    }
  }

  @Post('')
  @Require(..)
  @ValidateResponse(MessageResponseWithIdDataDTO)
  @Throws(NotAuthorizedException, ValidationException, InvalidUserException)
  async create(
    @Ctx('user') ctx: UserRequestContext,
    @Body() body: Create%sRequestDTO
  ): Promise<MessageResponseWithIdDataDTO> {
    const %s = await this.%s.create(ctx, body)

    return {
      message: ctx.translate('success.entity_created', {
        args: { entity: '%s' }
      }),
      data: { id: %s.id }
    }
  }

  @Patch('/:id')
  @Require(..)
  @ValidateResponse(MessageResponseWithIdDataDTO)
  @Throws(NotAuthorizedException, ValidationException, InvalidUserException)
  async update(
    @Ctx('user') ctx: UserRequestContext,
    @Param() param: IdDTO,
    @Body() body: %s
  ): Promise<MessageResponseWithIdDataDTO> {
    const %s = await this.%s.update(ctx, param.id, body)

    return {
      message: ctx.translate('success.entity_updated', { args: { entity: '%s' } }),
      data: { id: %s.id }
    }
  }

  @Delete('/:id')
  @Require(..)
  @ValidateResponse(MessageResponseDTO)
  @Throws(NotAuthorizedException, ValidationException, InvalidUserException)
  async delete(@Ctx('user') ctx: UserRequestContext, @Param() param: IdDTO): Promise<MessageResponseDTO> {
    await this.%s.delete(ctx, param.id)

    return { message: ctx.translate('success.entity_deleted', { args: { entity: '%s' } }) }
  }
}
]]):format(
		entityLower,
		controllerClassName,
		serviceVar,
		serviceClass,
		listResponse,
		entityPlural,
		listQuery,
		listResponse,
		entityLowerPlural,
		serviceVar,
		entityPlural,
		entityLowerPlural,
		entityLowerPlural,
		--
		getResponse,
		entityLower,
		getResponse,
		entityLower,
		serviceVar,
		entityName,
		entityLower,
		--
		entityName,
		entityLower,
		serviceVar,
		entityName,
		entityLower,
		--
		--
		updateDTO,
		entityLower,
		serviceVar,
		entityName,
		entityLower,
		--
		serviceVar,
		entityName
	)

	return vim.split(tpl, "\n")
end

function M.generate_controller_into_buffer()
	vim.ui.input({ prompt = "Controller class name (e.g. CandidateController): " }, function(controllerName)
		if not controllerName or controllerName == "" then
			vim.notify("Cancelled: controller name required", vim.log.levels.WARN)
			return
		end
		vim.ui.input({ prompt = "Entity name (e.g. Candidate): " }, function(entityName)
			if not entityName or entityName == "" then
				vim.notify("Cancelled: entity name required", vim.log.levels.WARN)
				return
			end

			local lines = generate_controller_content(controllerName, entityName)
			vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
			vim.notify("✅ Inserted NestJS controller for " .. entityName .. " in current buffer.")
		end)
	end)
end

------------------------------------------------------
-- KEYMAPS
------------------------------------------------------
vim.keymap.set(
	"n",
	"<leader>gns",
	M.generate_service_into_buffer,
	{ desc = "Generate NestJS Service in current buffer" }
)
vim.keymap.set(
	"n",
	"<leader>gnc",
	M.generate_controller_into_buffer,
	{ desc = "Generate NestJS Controller in current buffer" }
)

return M
