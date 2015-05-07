/**
 * \file list.h
 * A list of equilibrium. This is used to represent a group of
 * equilibria, either the positively indexed equilibria or the
 * negatively indexed equilibria. Nodes from one list are connected
 * to the other list via their link variable, which enables the
 * navigation of the bi-partite graph, of equilibria.
 *
 * Author: Tobenna Peter, Igwe  ptigwe@gmail.com  August, 2012
 */
#include "equilibrium.h"
#ifndef LIST_H
#define LIST_H

/**
 * A node structure used to represent a linked list.
 * Each node contains an Equilibrium which is unique to
 * that list, i.e. no two nodes in the list have the same
 * equilibrium. Each node also has a node element which
 * connects it to the next node in the list. Finally, each
 * node has an integer array link which connects the current
 * node in the list to a node in the opposite list with a given
 * label. For example if link[1] = 3, then this node is linked
 * to the 4th element in the other list with the label 2.
 * \sa Equilibrium
 */
typedef struct node_t
{
	Equilibrium eq;         /**< The Equilibrium stored in the node */
	int* link;              /**< The indexes of nodes it is connected to in the opposite list */
	struct node_t* next;    /**< The next element in the list */
}node;

/**
 * Creates a new node given the total number of labels.
 *
 * \param n Number of labels
 * \returns  A new node initialised for n labels
 */
node* newnode(int n);

/**
 * Returns the location of an equilibrium in the list.
 * Returns -1 if the equilibrium is not in the list.
 *
 * \param list  The list to be searched
 * \param eq    The equilibrium to search for
 * \returns     The index location of the equilibrium from 0 or 
 *              -1 if not in the list
 */
int contains(node* list, Equilibrium eq);

/**
 * Adds the equilibrium to the end of a list.
 * If the equilibrium already exists, it returns the 
 * index where it is stoeed, and doesn't add it.
 *
 * \param list  The list to add an Equilibrium to.
 * \param eq    The equilibrium to be added.
 * \returns     The index location of the equilibrium
 */
int addEquilibrium(node* list, Equilibrium eq);

/**
 * Returns the node at the index of the specified list.
 * If n is greater than or equal to the length of the list,
 * it returns NULL.
 *
 * \param list  The list
 * \param n     The index of the node in list
 * \returns     The node at the given index or NULL if there is no such index
 */
node* getNodeat(node* list, int n);

/**
 * Computes the number of elements in the list.
 *
 * \returns The length of the list 
 */
int listlength(node* list);

/**
 * Prints all the elements in the list.
 */
void printlist(node* list, char prefix);

#endif