/* A (pretty good) hash table implementation.
 * Copyright (C) 1993, 1994, 1995, 1996  Free Software Foundation, Inc.
 * 
 * Author: Albin L. Jones <Albin.L.Jones@Dartmouth.EDU>
 * Created: ??? ??? ?? ??:??:?? ??? 1993
 * Updated: Sat Feb 10 14:54:14 EST 1996
 * Serial: 96.02.10.05
 * 
 * This file is part of the GNU Objective C Class Library.
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 * 
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the Free
 * Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 * 
 */ 

/**** Included Headers *******************************************************/

#include <objects/allocs.h>
#include <objects/callbacks.h>
#include <objects/hash.h>

/**** Function Implementations ***********************************************/

/** Behind-the-Scenes functions **/

objects_hash_bucket_t *
_objects_hash_pick_bucket_for_element (objects_hash_t *hash,
				       objects_hash_bucket_t *buckets,
				       size_t bucket_count,
				       void *element)
{
  return buckets + (objects_hash (objects_hash_element_callbacks (hash),
				  element, hash) % bucket_count);
}

objects_hash_bucket_t *
_objects_hash_pick_bucket_for_node (objects_hash_t * hash,
				    objects_hash_bucket_t * buckets,
				    size_t bucket_count,
				    objects_hash_node_t * node)
{
  return buckets + (objects_hash (objects_hash_element_callbacks (hash),
				  node->element, hash) % bucket_count);
}

objects_hash_bucket_t *
_objects_hash_bucket_for_element (objects_hash_t * hash, void *element)
{
  return _objects_hash_pick_bucket_for_element (hash, hash->buckets,
						hash->bucket_count, element);
}

objects_hash_bucket_t *
_objects_hash_bucket_for_node (objects_hash_t * hash, objects_hash_node_t * node)
{
  return _objects_hash_pick_bucket_for_node (hash, hash->buckets,
					     hash->bucket_count, node);
}

void
_objects_hash_link_node_into_bucket (objects_hash_bucket_t * bucket,
				     objects_hash_node_t * node)
{
  if (bucket->first_node != NULL)
    bucket->first_node->prev_in_bucket = node;

  node->next_in_bucket = bucket->first_node;

  bucket->first_node = node;

  return;
}

void
_objects_hash_unlink_node_from_its_bucket (objects_hash_node_t * node)
{
  if (node == node->bucket->first_node)
    node->bucket->first_node = node->next_in_bucket;

  if (node->prev_in_bucket != NULL)
    node->prev_in_bucket->next_in_bucket = node->next_in_bucket;
  if (node->next_in_bucket != NULL)
    node->next_in_bucket->prev_in_bucket = node->prev_in_bucket;

  node->prev_in_bucket = node->next_in_bucket = NULL;

  return;
}

void
_objects_hash_link_node_into_hash (objects_hash_t * hash, objects_hash_node_t * node)
{
  if (hash->first_node != NULL)
    hash->first_node->prev_in_hash = node;

  node->next_in_hash = hash->first_node;

  hash->first_node = node;

  return;
}

void
_objects_hash_unlink_node_from_its_hash (objects_hash_node_t * node)
{
  if (node == node->hash->first_node)
    node->hash->first_node = node->next_in_hash;

  if (node->prev_in_hash != NULL)
    node->prev_in_hash->next_in_hash = node->next_in_hash;
  if (node->next_in_hash != NULL)
    node->next_in_hash->prev_in_hash = node->prev_in_hash;

  node->prev_in_hash = node->next_in_hash = NULL;

  return;
}

void
_objects_hash_add_node_to_bucket (objects_hash_bucket_t * bucket, objects_hash_node_t * node)
{
  if (bucket != NULL)
    {
      _objects_hash_link_node_into_bucket (bucket, node);

      node->bucket = bucket;

      bucket->node_count += 1;
      bucket->element_count += 1;
    }

  return;
}

void
_objects_hash_add_node_to_its_bucket (objects_hash_t * hash, objects_hash_node_t * node)
{
  _objects_hash_add_node_to_bucket (_objects_hash_bucket_for_node (hash, node), node);
  return;
}

void
_objects_hash_add_node_to_hash (objects_hash_t * hash, objects_hash_node_t * node)
{
  if (hash != NULL)
    {
      _objects_hash_add_node_to_its_bucket (hash, node);

      _objects_hash_link_node_into_hash (hash, node);

      node->hash = hash;

      hash->node_count += 1;
      hash->element_count += 1;
    }

  return;
}

void
_objects_hash_remove_node_from_its_bucket (objects_hash_node_t * node)
{
  if (node->bucket != NULL)
    {
      node->bucket->node_count -= 1;
      node->bucket->element_count -= 1;

      _objects_hash_unlink_node_from_its_bucket (node);
    }

  return;
}

void
_objects_hash_remove_node_from_its_hash (objects_hash_node_t * node)
{
  if (node->hash != NULL)
    {
      node->hash->node_count -= 1;
      node->hash->element_count -= 1;

      _objects_hash_unlink_node_from_its_hash (node);
    }

  _objects_hash_remove_node_from_its_bucket (node);

  return;
}

objects_hash_bucket_t *
_objects_hash_new_buckets (objects_hash_t *hash, size_t bucket_count)
{
  return (objects_hash_bucket_t *) objects_calloc (objects_hash_allocs (hash),
						   bucket_count,
					           sizeof (objects_hash_bucket_t));
}

void
_objects_hash_free_buckets (objects_hash_t *hash, objects_hash_bucket_t *buckets)
{
  if (buckets != NULL)
    objects_free (objects_hash_allocs (hash), buckets);
  return;
}

void
_objects_hash_remangle_buckets (objects_hash_t * hash,
				objects_hash_bucket_t * old_buckets,
				size_t old_bucket_count,
				objects_hash_bucket_t * new_buckets,
				size_t new_bucket_count)
{
  size_t i;
  objects_hash_node_t *node;

  for (i = 0; i < old_bucket_count; i++)
    {
      while ((node = old_buckets[i].first_node) != NULL)
	{
	  _objects_hash_remove_node_from_its_bucket (node);
	  _objects_hash_add_node_to_bucket (_objects_hash_pick_bucket_for_node (hash,
								new_buckets,
							   new_bucket_count,
								      node),
					    node);
	}
    }

  /* And that's that. */
  return;
}

objects_hash_node_t *
_objects_hash_new_node (objects_hash_t * hash, void *element)
{
  objects_hash_node_t *node;

  /* Allocate the space for a new node. */
  node = (objects_hash_node_t *) objects_malloc (objects_hash_allocs (hash),
					      sizeof (objects_hash_node_t));

  if (node != NULL)
    {
      /* Retain ELEMENT.  (It's released in `_objects_hash_free_node()'.) */
      objects_retain (objects_hash_element_callbacks (hash), element, hash);

      /* Remember ELEMENT. */
      node->element = element;

      /* Zero out the various pointers. */
      node->hash = NULL;
      node->bucket = NULL;
      node->next_in_bucket = NULL;
      node->next_in_hash = NULL;
      node->prev_in_bucket = NULL;
      node->prev_in_hash = NULL;
    }

  return node;
}

void
_objects_hash_free_node (objects_hash_node_t * node)
{
  if (node != NULL)
    {
      objects_hash_t *hash;

      /* Remember NODE's hash. */
      hash = node->hash;

      /* Release ELEMENT.  (It's retained in `_objects_hash_new_node()'.) */
      objects_release (objects_hash_element_callbacks (hash), node->element, hash);

      /* Actually free the space hash aside for NODE. */
      objects_free (objects_hash_allocs (hash), node);
    }

  /* And just return. */
  return;
}

objects_hash_node_t *
_objects_hash_node_for_element (objects_hash_t * hash, void *element)
{
  objects_hash_bucket_t *bucket;
  objects_hash_node_t *node;

  /* Find the bucket in which the node for ELEMENT would be. */
  bucket = _objects_hash_bucket_for_element (hash, element);

  /* Run through the nodes in BUCKET until we find one whose element
   * matches ELEMENT. */
  for (node = bucket->first_node;
  (node != NULL) && !objects_is_equal (objects_hash_element_callbacks (hash),
				       element,
				       node->element,
				       hash);
       node = node->next_in_bucket);

  /* Note that if none of the nodes' elements matches ELEMENT, then we
   * naturally return `NULL'. */
  return node;
}

objects_hash_node_t *
_objects_hash_enumerator_next_node (objects_hash_enumerator_t * enumerator)
{
  objects_hash_node_t *node;

  /* Remember ENUMERATOR's current node. */
  node = enumerator->node;

  /* If NODE is a real node, then we need to increment ENUMERATOR's
   * current node to the next node in ENUMERATOR's hash. */
  if (node != NULL)
    enumerator->node = enumerator->node->next_in_hash;

  /* Send back NODE. */
  return node;
}

/** Hashing **/

size_t
objects_hash_hash (objects_hash_t * hash)
{
  /* FIXME: Code this. */
  return 0;
}

/** Resizing **/

size_t
objects_hash_resize (objects_hash_t * hash, size_t new_capacity)
{
  objects_hash_bucket_t *new_buckets;

  /* Round NEW_CAPACITY up to the next power of two. */
  new_capacity = objects_next_power_of_two (new_capacity);

  /* Make a new hash of buckets. */
  new_buckets = _objects_hash_new_buckets (hash, new_capacity);

  if (new_buckets != NULL)
    {
      _objects_hash_remangle_buckets (hash,
				      hash->buckets,
				      hash->bucket_count,
				      new_buckets,
				      new_capacity);

      _objects_hash_free_buckets (hash, hash->buckets);

      hash->buckets = new_buckets;
      hash->bucket_count = new_capacity;

    }

  /* Return the new capacity. */
  return hash->bucket_count;
}

size_t
objects_hash_rightsize (objects_hash_t * hash)
{
  /* FIXME: Now, this is a guess, based solely on my intuition.  If
   * anyone knows of a better ratio (or other test, for that matter)
   * and can provide evidence of its goodness, please get in touch
   * with me, Albin L. Jones <albin.l.jones@dartmouth.edu>. */

  if (3 * hash->node_count > 4 * hash->bucket_count)
    {
      return objects_hash_resize (hash, hash->bucket_count + 1);
    }
  else
    {
      return hash->bucket_count;
    }
}

/** Statistics **/

size_t
objects_hash_count (objects_hash_t * hash)
{
  return hash->element_count;
}

size_t
objects_hash_capacity (objects_hash_t * hash)
{
  return hash->bucket_count;
}

int
objects_hash_check (objects_hash_t * hash)
{
  /* FIXME: Code this. */
  return 0;
}

/** Searching **/

int
objects_hash_contains_element (objects_hash_t * hash, void *element)
{
  objects_hash_node_t *node;

  node = _objects_hash_node_for_element (hash, element);

  return node != NULL;
}

void *
objects_hash_element (objects_hash_t * hash, void *element)
{
  objects_hash_node_t *node;

  /* Try and find the node for ELEMENT. */
  node = _objects_hash_node_for_element (hash, element);

  if (node != NULL)
    return node->element;
  else
    return objects_hash_not_an_element_marker (hash);
}

void **
objects_hash_all_elements (objects_hash_t * hash)
{
  size_t j;
  void **array;
  objects_hash_enumerator_t enumerator;

  /* Allocate space for ARRAY.  Remember that it is the programmer's
   * responsibility to free this by calling
   * `objects_free(objects_hash_allocs(HASH), ARRAY)' */
  array = (void **) objects_calloc (objects_hash_allocs (hash),
				    hash->node_count + 1,
				    sizeof (void *));

  /* ENUMERATOR is an enumerator for HASH. */
  enumerator = objects_hash_enumerator (hash);

  /* Now we enumerate through the elements of HASH, adding them
   * one-by-one to ARRAY.  */
  for (j = 0; j < hash->node_count; j++)
    objects_hash_enumerator_next_element (&enumerator, array + j);

  /* We terminate ARRAY with the `not_an_element_marker' for HASH. */
  array[j] = objects_hash_not_an_element_marker (hash);

  /* And we're done. */
  return array;
}

int
objects_hash_is_empty (objects_hash_t * hash)
{
  return objects_hash_count (hash) == 0;
}

/** Enumerating **/

/* WARNING: You should not alter a hash while an enumeration is
 * in progress.  The results of doing so are reasonably unpredictable.
 * With that in mind, read the following warnings carefully.  But
 * remember, DON'T MESS WITH A HASH WHILE YOU'RE ENUMERATING IT. */

/* IMPORTANT WARNING: Hash enumerators, as I have hash them up, have a
 * wonderous property.  Namely, that, while enumerating, one may add
 * new elements (i.e., new nodes) to the hash while an enumeration is
 * in progress (i.e., after `objects_hash_enumerator()' has been called), and
 * the enumeration remains the same. */

/* WARNING: The above warning should not, in any way, be taken as
 * assurance that this property of hash enumerators will be preserved
 * in future editions of the library.  I'm still thinking about
 * this. */

/* IMPORTANT WARNING: Enumerators have yet another wonderous property.
 * Once a node has been returned by
 * `_objects_hash_enumerator_next_node()', it may be removed from the hash
 * without effecting the rest of the current enumeration.  For
 * example, to clean all of the nodes out of a hash, the following code
 * would work:
 * 
 * void
 * empty_my_hash(objects_hash_t *hash)
 * {
 *   objects_hash_enumerator_t enumerator = objects_hash_enumerator(hash);
 *   objects_hash_node_t *node;
 * 
 *   while ((node = _objects_hash_enumerator_next_node(&enumerator)) != NULL)
 *   {
 *     _objects_hash_remove_node_from_its_hash(node);
 *     _objects_hash_free_node(node);
 *   }
 * 
 *   return;
 * }
 * 
 * (In fact, this is the code currently being used below in the
 * function `objects_hash_empty()'.)  But again, this is not to be taken
 * as an assurance that this behaviour will persist in future versions
 * of the library. */

/* EXTREMELY IMPORTANT WARNING: The purpose of this warning is point
 * out that, at this time, various (i.e., many) functions depend on
 * the behaviours outlined above.  So be prepared for some serious
 * breakage when you go fudging around with these things. */

objects_hash_enumerator_t
objects_hash_enumerator (objects_hash_t * hash)
{
  objects_hash_enumerator_t enumerator;

  /* Make sure ENUMERATOR knows its hash. */
  enumerator.hash = hash;

  /* Start ENUMERATOR at HASH's first node. */
  enumerator.node = hash->first_node;

  return enumerator;
}

int
objects_hash_enumerator_next_element (objects_hash_enumerator_t * enumerator,
				      void **element)
{
  objects_hash_node_t *node;

  /* Get the next node in the enumeration represented by
   * ENUMERATOR. */
  node = _objects_hash_enumerator_next_node (enumerator);

  if (node != NULL)
    {
      /* NODE is real, so we pull the information out of it that we
       * need.  Note that we check to see whether ELEMENT and COUNT are
       * non-`NULL'. */
      if (element != NULL)
	*element = node->element;

      /* Since we weren't at the end of our enumeration, we return
       * ``true''. */
      return 1;
    }
  else
    {
      /* If NODE isn't real, then we return the bogus element indicator
       * and a zero count. */
      if (element != NULL)
	*element = objects_hash_not_an_element_marker (enumerator->hash);

      /* Since we're at the end of the enumeration, we return
       * ``false''. */
      return 0;
    }
}

/** Adding **/

void *
objects_hash_add_element_known_absent (objects_hash_t * hash, void *element)
{
  objects_hash_node_t *node;

  node = _objects_hash_new_node (hash, element);

  if (node != NULL)
    {
      /* Actually add NODE to HASH. */
      _objects_hash_add_node_to_hash (hash, node);

      return node->element;
    }
  else
    {
      return objects_hash_not_an_element_marker (hash);
    }
}

void *
objects_hash_add_element (objects_hash_t * hash, void *element)
{
  objects_hash_node_t *node;

  /* First, we check for ELEMENT in HASH. */
  node = _objects_hash_node_for_element (hash, element);

  if (node == NULL)
    {
      /* ELEMENT isn't in HASH, so we can add it with impunity. */
      return objects_hash_add_element_known_absent (hash, element);
    }
  else
    {
      objects_retain (objects_hash_element_callbacks (hash), element, hash);
      objects_release (objects_hash_element_callbacks (hash), node->element, hash);
      return node->element = element;
    }
}

void *
objects_hash_add_element_if_absent (objects_hash_t * hash, void *element)
{
  objects_hash_node_t *node;

  /* First, we check for ELEMENT in HASH. */
  node = _objects_hash_node_for_element (hash, element);

  if (node == NULL)
    {
      /* ELEMENT isn't in HASH, so we can add it with impunity. */
      return objects_hash_add_element_known_absent (hash, element);
    }

  return node->element;
}

/** Removing **/

void
objects_hash_remove_element (objects_hash_t * hash, void *element)
{
  objects_hash_node_t *node;

  node = _objects_hash_node_for_element (hash, element);

  if (node != NULL)
    {
      /* Pull NODE out of HASH. */
      _objects_hash_remove_node_from_its_hash (node);

      /* Free up NODE. */
      _objects_hash_free_node (node);
    }

  return;
}

/** Emptying **/

void
objects_hash_empty (objects_hash_t * hash)
{
  objects_hash_enumerator_t enumerator;
  objects_hash_node_t *node;

  /* Get an element enumerator for HASH. */
  enumerator = objects_hash_enumerator (hash);

  /* Just step through the nodes of HASH and wipe them out, one after
   * another.  Don't try this at home, kids!  Note that, under
   * ordinary circumstances, this would be a verboten use of
   * hash enumerators.  See the warnings with the enumerator
   * functions for more details. */
  while ((node = _objects_hash_enumerator_next_node (&enumerator)) != NULL)
    {
      _objects_hash_remove_node_from_its_hash (node);
      _objects_hash_free_node (node);
    }

  /* And return. */
  return;
}

/** Creating **/

objects_hash_t *
objects_hash_alloc_with_allocs (objects_allocs_t allocs)
{
  objects_hash_t *hash;

  /* Get a new hash. */
  hash = _objects_hash_alloc_with_allocs (allocs);

  return hash;
}

objects_hash_t *
objects_hash_alloc (void)
{
  return objects_hash_alloc_with_allocs (objects_allocs_standard());
}

objects_hash_t *
objects_hash_with_callbacks (objects_callbacks_t callbacks)
{
  return objects_hash_init_with_callbacks (objects_hash_alloc (), callbacks);
}

objects_hash_t *
objects_hash_with_allocs_with_callbacks (objects_allocs_t allocs,
					 objects_callbacks_t callbacks)
{
  return objects_hash_init_with_callbacks (objects_hash_alloc_with_allocs (allocs),
					   callbacks);
}

objects_hash_t *
objects_hash_with_allocs (objects_allocs_t allocs)
{
  return objects_hash_init (objects_hash_alloc_with_allocs (allocs));
}

objects_hash_t *
objects_hash_of_char_p (void)
{
  return objects_hash_with_callbacks (objects_callbacks_for_char_p);
}

objects_hash_t *
objects_hash_of_void_p (void)
{
  return objects_hash_with_callbacks (objects_callbacks_for_void_p);
}

objects_hash_t *
objects_hash_of_owned_void_p (void)
{
  return objects_hash_with_callbacks (objects_callbacks_for_owned_void_p);
}

objects_hash_t *
objects_hash_of_int (void)
{
  return objects_hash_with_callbacks (objects_callbacks_for_int);
}

objects_hash_t *
objects_hash_of_id (void)
{
  return objects_hash_with_callbacks (objects_callbacks_for_id);
}

/** Initializing **/

objects_hash_t *
objects_hash_init_with_callbacks (objects_hash_t * hash,
				  objects_callbacks_t callbacks)
{
  if (hash != NULL)
    {
      size_t capacity = 10;

      /* Make a note of the callbacks and allocs for HASH. */
      hash->callbacks = objects_callbacks_standardize (callbacks);

      /* Zero out the various counts. */
      hash->node_count = 0;
      hash->bucket_count = 0;
      hash->element_count = 0;

      /* Zero out the pointers. */
      hash->first_node = NULL;
      hash->buckets = NULL;

      /* Resize HASH to the given CAPACITY. */
      objects_hash_resize (hash, capacity);
    }

  /* Return the newly initialized HASH. */
  return hash;
}

objects_hash_t *
objects_hash_init (objects_hash_t * hash)
{
  return objects_hash_init_with_callbacks (hash, objects_callbacks_standard());
}

objects_hash_t *
objects_hash_init_from_hash (objects_hash_t * hash, objects_hash_t * old_hash)
{
  if (hash != NULL)
    {
      objects_hash_enumerator_t enumerator;
      void *element;

      /* Make a note of the callbacks for HASH. */
      hash->callbacks = objects_hash_element_callbacks (hash);

      /* Zero out the various counts. */
      hash->node_count = 0;
      hash->bucket_count = 0;
      hash->element_count = 0;

      /* Zero out the pointers. */
      hash->first_node = NULL;
      hash->buckets = NULL;

      /* Resize HASH to the given CAPACITY. */
      objects_hash_resize (hash, objects_hash_capacity (old_hash));

      /* Get an element enumerator for OLD_HASH. */
      enumerator = objects_hash_enumerator (old_hash);

      /* Add OLD_HASH's elements to HASH, one at a time. */
      while (objects_hash_enumerator_next_element (&enumerator, &element))
	objects_hash_add_element_known_absent (hash, element);
    }

  /* Return the newly initialized HASH. */
  return hash;
}

/** Destroying **/

void
objects_hash_dealloc (objects_hash_t * hash)
{
  /* Remove all of HASH's elements. */
  objects_hash_empty (hash);

  /* Free up the bucket array. */
  _objects_hash_free_buckets (hash, hash->buckets);

  /* And finally, perform the ultimate sacrifice. */
  _objects_hash_dealloc (hash);

  return;
}

/** Replacing **/

void
objects_hash_replace_element (objects_hash_t * hash, void *element)
{
  objects_hash_node_t *node;

  /* Lookup the node for ELEMENT. */
  node = _objects_hash_node_for_element (hash, element);

  if (node != NULL)
    {
      /* Remember: First retain the new element, then release the old
       * element, just in case they're the same. */
      objects_retain (objects_hash_element_callbacks (hash), element, hash);
      objects_release (objects_hash_element_callbacks (hash), node->element, hash);
      node->element = element;
    }

  return;
}

/** Comparing **/

/* Returns true if HASH1 is a superset of HASH2. */
int
objects_hash_contains_hash (objects_hash_t * hash1, objects_hash_t * hash2)
{
  objects_hash_enumerator_t enumerator;
  void *element;

  enumerator = objects_hash_enumerator (hash2);

  while (objects_hash_enumerator_next_element (&enumerator, &element))
    if (!objects_hash_contains_element (hash1, element))
      return 0;

  return 1;
}

/* Returns true if HASH1 is both a superset and a subset of HASH2.
 * Checks to make sure HASH1 and HASH2 have the same number of
 * elements first. */
int
objects_hash_is_equal_to_hash (objects_hash_t * hash1, objects_hash_t * hash2)
{
  size_t a, b;

  /* Count HASH1 and HASH2. */
  a = objects_hash_count (hash1);
  b = objects_hash_count (hash2);

  /* Check the counts. */
  if (a != b)
    return 0;

  /* If the counts match, then we do an element by element check. */
  if (!objects_hash_contains_hash (hash1, hash2)
      || !objects_hash_contains_hash (hash2, hash1))
    return 0;

  /* If we made it this far, HASH1 and HASH2 are the same. */
  return 1;
}

/* Returns true if HASH and OTHER_HASH have at least one element in
 * common. */
int
objects_hash_intersects_hash (objects_hash_t * hash, objects_hash_t * other_hash)
{
  objects_hash_enumerator_t enumerator;
  void *element;

  /* Get an element enumerator for OTHER_HASH. */
  enumerator = objects_hash_enumerator (other_hash);

  while (objects_hash_enumerator_next_element (&enumerator, &element))
    if (objects_hash_contains_element (hash, element))
      return 1;

  return 0;
}

/** Copying **/

/* Returns a new copy of OLD_HASH, using NEW_ALLOCS. */
objects_hash_t *
objects_hash_copy_with_allocs (objects_hash_t * old_hash, objects_allocs_t new_allocs)
{
  objects_hash_t *new_hash;

  /* Alloc the NEW_HASH, copying over the low-level stuff. */
  new_hash = _objects_hash_copy_with_allocs (old_hash, new_allocs);

  /* Initialize the NEW_HASH. */
  objects_hash_init_from_hash (new_hash, old_hash);

  /* Return the NEW_HASH. */
  return new_hash;
}

/* Returns a new copy of OLD_HASH, using OLD_HASH's allocs. */
objects_hash_t *
objects_hash_copy (objects_hash_t * old_hash)
{
  /* FIXME: Should I be using `objects_allocs_standard()', or
   * `objects_hash_allocs(old_hash)'? */
  return objects_hash_copy_with_allocs (old_hash, objects_hash_allocs (old_hash));
}

/** Mapping **/

/* WARNING: The mapping function FCN must be one-to-one on elements of
 * HASH.  I.e., for reasons of efficiency, `objects_hash_map_elements()'
 * makes no provision for the possibility that FCN maps two unequal
 * elements of HASH to the same (or equal) elements.  The better way
 * to handle functions that aren't one-to-one is to create a new hash
 * and transform the elements of the first to create the elements of
 * the second. */
objects_hash_t *
objects_hash_map_elements (objects_hash_t * hash,
			   void *(*fcn) (void *, void *),
			   void *user_data)
{
  objects_hash_enumerator_t enumerator;
  objects_hash_node_t *node;

  enumerator = objects_hash_enumerator (hash);

  while ((node = _objects_hash_enumerator_next_node (&enumerator)) != NULL)
    {
      void *element;

      element = (*fcn) (node->element, user_data);

      /* Remember: First retain the new element, then release the old
       * element. */
      objects_retain (objects_hash_element_callbacks (hash), element, hash);
      objects_release (objects_hash_element_callbacks (hash), node->element, hash);
      node->element = element;
    }

  return hash;
}

/** Miscellaneous **/

/* Removes the elements of HASH which do not occur in OTHER_HASH. */
objects_hash_t *
objects_hash_intersect_hash (objects_hash_t * hash, objects_hash_t * other_hash)
{
  objects_hash_enumerator_t enumerator;
  objects_hash_node_t *node;

  enumerator = objects_hash_enumerator (hash);

  while ((node = _objects_hash_enumerator_next_node (&enumerator)) != NULL)
    if (!objects_hash_contains_element (other_hash, node->element))
      {
	_objects_hash_remove_node_from_its_hash (node);
	_objects_hash_free_node (node);
      }

  return hash;
}

/* Removes the elements of HASH which occur in OTHER_HASH. */
objects_hash_t *
objects_hash_minus_hash (objects_hash_t * hash, objects_hash_t * other_hash)
{
  objects_hash_enumerator_t enumerator;
  objects_hash_node_t *node;

  enumerator = objects_hash_enumerator (hash);

  while ((node = _objects_hash_enumerator_next_node (&enumerator)) != NULL)
    if (objects_hash_contains_element (other_hash, node->element))
      {
	_objects_hash_remove_node_from_its_hash (node);
	_objects_hash_free_node (node);
      }

  return hash;
}

/* Adds to HASH those elements of OTHER_HASH not occurring in HASH. */
objects_hash_t *
objects_hash_union_hash (objects_hash_t * hash, objects_hash_t * other_hash)
{
  objects_hash_enumerator_t enumerator;
  void *element;

  enumerator = objects_hash_enumerator (other_hash);

  while (objects_hash_enumerator_next_element (&enumerator, &element))
    objects_hash_add_element (hash, element);

  return hash;
}

