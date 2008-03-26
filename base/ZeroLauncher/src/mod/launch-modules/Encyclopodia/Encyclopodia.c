/*
 * Last updated: March 14, 2008
 * ~Keripo
 *
 * Copyright (C) 2008 Keripo
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#include "pz.h"

extern void pz_exec();

static PzModule *module;

static PzWindow *fastlaunch()
{
	pz_message("Note: Encyclopodia requires large amounts of memory and may not work here.");
	pz_message("You should try launching Encyclopodia from Loader2 instead (see the \"/boot/loader.cfg\" file).");
	pz_exec(pz_module_get_datapath(module, "FastLaunch.sh"));
	return NULL;
}

static void init_launch() 
{
	module = pz_register_module ("Encyclopodia", 0);
	pz_menu_add_action_group ("/Tools/Encyclopodia", "Reference", fastlaunch);
}

PZ_MOD_INIT (init_launch)