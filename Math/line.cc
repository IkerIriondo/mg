#include <cassert>
#include <cstdio>
#include <cstdlib>
#include "line.h"
#include "constants.h"
#include "tools.h"

Line::Line() : m_O(Vector3::ZERO), m_d(Vector3::UNIT_Y) {}
Line::Line(const Vector3 & o, const Vector3 & d) : m_O(o), m_d(d) {}
Line::Line(const Line & line) : m_O(line.m_O), m_d(line.m_d) {}

Line & Line::operator=(const Line & line) {
	if (&line != this) {
		m_O = line.m_O;
		m_d = line.m_d;
	}
	return *this;
}

// @@ TODO: Set line to pass through two points A and B
//
// Note: Check than A and B are not too close!

void Line::setFromAtoB(const Vector3 & A, const Vector3 & B) {
	/* =================== PUT YOUR CODE HERE ====================== */
	Vector3 ab = B - A;
	assert(!ab.isZero());
	m_O = A;
	m_d = ab.normalize();
	/* =================== END YOUR CODE HERE ====================== */
}

// @@ TODO: Give the point corresponding to parameter u

Vector3 Line::at(float u) const {
	Vector3 res;
	/* =================== PUT YOUR CODE HERE ====================== */
	res = m_O + u*m_d;
	/* =================== END YOUR CODE HERE ====================== */
	return res;
}

// @@ TODO: Calculate the parameter 'u0' of the line point nearest to P
//
// u0 = m_d*(P-m_o) / m_d*m_d , where * == dot product

float Line::paramDistance(const Vector3 & P) const {
	float res = 0.0f;
	/* =================== PUT YOUR CODE HERE ====================== */
	Vector3 po = P - m_O;
	float u0 = m_d.dot(po)/m_d.dot(m_d);
	res = u0;
	/* =================== END YOUR CODE HERE ====================== */
	return res;
}

// @@ TODO: Calculate the minimum distance 'dist' from line to P
//
// dist = ||P - (m_o + u0*m_d)||
// Where u0 = paramDistance(P)

float Line::distance(const Vector3 & P) const {
	float res = 0.0f;
	/* =================== PUT YOUR CODE HERE ====================== */
	float u0 = paramDistance(P);
	Vector3 p1 = at(u0);
	Vector3 resv = P - p1;
	res = resv.length();
	/* =================== END YOUR CODE HERE ====================== */
	return res;
}

void Line::print() const {
	printf("O:");
	m_O.print();
	printf(" d:");
	m_d.print();
	printf("\n");
}
