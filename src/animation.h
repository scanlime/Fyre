/*
 * animation.h - A simple keyframe animation system for DeJong objects
 *
 * de Jong Explorer - interactive exploration of the Peter de Jong attractor
 * Copyright (C) 2004 David Trowbridge and Micah Dowty
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 *
 */

#ifndef __ANIMATION_H__
#define __ANIMATION_H__

#include "de-jong.h"

G_BEGIN_DECLS

#define ANIMATION_TYPE            (animation_get_type ())
#define ANIMATION(obj)            (G_TYPE_CHECK_INSTANCE_CAST ((obj), ANIMATION_TYPE, Animation))
#define ANIMATION_CLASS(klass)    (G_TYPE_CHECK_CLASS_CAST ((klass), ANIMATION_TYPE, AnimationClass))
#define IS_ANIMATION(obj)         (G_TYPE_CHECK_INSTANCE_TYPE ((obj), ANIMATION_TYPE))
#define IS_ANIMATION_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), ANIMATION_TYPE))

typedef struct _Animation      Animation;
typedef struct _AnimationClass AnimationClass;

struct _Animation {
  GObject object;

  GtkListStore *model;
};

struct _AnimationClass {
  GObjectClass parent_class;
};

/* Items in the GdkListStore holding our keyframes */
enum {
  ANIMATION_MODEL_THUMBNAIL,    /* The thumbnail, as a GdkPixbuf */
  ANIMATION_MODEL_PARAMS,       /* The DeJong parameters, as a string */
  ANIMATION_MODEL_DURATION,     /* The duration of the following transition, in seconds */
};


/************************************************************************************/
/******************************************************************* Public Methods */
/************************************************************************************/

GType        animation_get_type();
Animation*   animation_new();

void         animation_keyframe_store_dejong(Animation *self, GtkTreeIter *iter, DeJong *dejong);
void         animation_keyframe_load_dejong(Animation *self, GtkTreeIter *iter, DeJong *dejong);
void         animation_keyframe_append(Animation *self, DeJong *dejong);

void         animation_load_file(Animation *self, const gchar *filename);
void         animation_save_file(Animation *self, const gchar *filename);

G_END_DECLS

#endif /* __ANIMATION_H__ */

/* The End */