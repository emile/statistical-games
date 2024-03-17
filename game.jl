# section 2.5 strategy plots
# https://arxiv.org/abs/2402.15892
# József Konczer

# todo: scale quadrants to correct proportions

using Combinatorics
using Plots

struct game
	n::Int
	ka::Int
	kb::Int
	m::Int
end

function pk(g::game, k::Int)::Float64
	binomial(g.ka, k) * binomial(g.m - g.ka, g.n - k ) / binomial(g.m, g.n)
end

function flipgame(g::game)::game
	game(g.n, g.kb, g.ka, g.m)
end

function kstar(g::game)::Int
	fg = flipgame(g)
	totalp = 0
	k = -1
	while totalp <= 1 && k < g.n
		k += 1
		p = pk(g, k) + pk(fg, k)
		totalp += p
	end
	k

function pstar(g::game, ks::Int)::Float64
	fg = flipgame(g)
	pk(fg, ks) / pk(g, ks) + pk(fg, ks)
end

function nustar(g::game, ks::Int)::Float64
	fg = flipgame(g)
	sum_numenator = 0.0
	for k = 0:g.n
		if k >= ks
			value = pk(fg, k)
		else
			value = -pk(g, k)
		end
		sum_numenator += value
	end
	denom = pk(g, ks) + pk(fg, ks)
	sum_numenator / denom
end


function player1guess(k::Int, ks::Int, ns::Float64)::Int
	if k < ks
		0
	elseif k > ks
		1
	elseif ns > 0.5
		0
	else
		1
	end
end

function play(g::game)
	ks = kstar(g)
	ns = nustar(g, ks)
	size_xa = binomial(g.m, g.ka)
	size_xb = binomial(g.m, g.kb)
	size_y = binomial(g.m, g.n)
	result = Matrix{Int}(undef,  size_y * 2, size_xa + size_xb)
	Threads.@threads for (index2, player2bits) in collect(enumerate(combinations(1:g.m, g.kb)))
		for (index1, player1bits) in enumerate(combinations(1:g.m, g.n))
			k = length(intersect(player1bits, player2bits))
			result[index1, index2] = player1guess(k, ks, ns)
			result[index1 + size_y, index2] = player1guess(k, ks, 1-ns)
		end
	end
	Threads.@threads for (index2, player2bits) in collect(enumerate(combinations(1:g.m, g.ka)))
		for (index1, player1bits) in enumerate(combinations(1:g.m, g.n))
			k = length(intersect(player1bits, player2bits))
			result[index1, index2 + size_xb] = player1guess(k, ks, ns)
			result[index1 + size_y, index2 + size_xb] = player1guess(k, ks, 1-ns)
		end
	end
	result
end

solution = play(game(4, 4, 6, 10))
heatmap(solution)

