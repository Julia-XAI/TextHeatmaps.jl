# The abstract type `AbstractTransform` is defined in XAIBase.jl.
# Custom heatmapping transforms subtype it and implement `apply`.

"""
    apply(t::AbstractTransform, x)

Apply a transform `t` of type `AbstractTransform` to the input `x`.

Custom heatmapping transforms subtype `AbstractTransform`
and must implement an `apply(t, x::AbstractArray)` method for single samples.
Batches of type `XAIBase.Batch` are transformed sample by sample by default.
Batch-aware transforms can implement `apply(t, xs::Batch)`.
"""
apply(t::AbstractTransform, xs::Batch) = mapsamples(x -> apply(t, x), xs)

# Pooling functions reduce the feature dimension, which is then dropped.
# Text attributions follow the convention (features, input length, batch dimension),
# such that features are the first dimension of both single samples and batches.
apply(p::AbstractPooling, x::AbstractMatrix) = pool(p, x, 1)
apply(p::AbstractPooling, xs::Batch{<:AbstractArray{<:Any, 3}}) = pool(p, xs, 1)

# Attributions without a feature dimension are pooled as if they had a single feature.
apply(p::AbstractPooling, x::AbstractVector) = pool(p, add_feature_dim(x), 1)
function apply(p::AbstractPooling, xs::Batch{<:AbstractMatrix})
    return pool(p, add_feature_dim(xs), 1)
end

add_feature_dim(x::AbstractArray) = reshape(x, 1, size(x)...)
add_feature_dim(xs::Batch) = Batch(add_feature_dim(xs.val); dims = xs.dims + 1)

# Normalization functions from XAIBase handle batches,
# e.g. to normalize the whole batch at once using `BatchedNormalization`.
apply(n::AbstractNormalization, x::AbstractArray) = normalize(n, x)
apply(n::AbstractNormalization, xs::Batch) = normalize(n, xs)

"""
    Colormap()
    Colormap(name::Symbol)
    Colormap(name::Symbol, colormap)

Apply a `colormap` from ColorSchemes.jl, turning an array of values into an array of colors.
Defaults to `:batlow`.

Values are expected to be normalized to the unit interval `[0, 1]`, e.g. by `ExtremaNormalization()` or `CenteredNormalization()` from XAIBase.jl.
Values outside of this interval are clamped.

Normalizations are meant to be paired with a kind of colormap:
`ExtremaNormalization` with sequential colormaps (e.g. `:batlow`),
`CenteredNormalization` with diverging colormaps (e.g. `:berlin`).
Composing a normalization with a colormap that ColorSchemes.jl describes as the other kind emits a warning.
"""
struct Colormap <: AbstractTransform
    name::Symbol
    colormap::ColorScheme
end
Colormap(name::Symbol) = Colormap(name, colorschemes[name])
Colormap() = Colormap(:batlow)

Base.show(io::IO, t::Colormap) = print(io, "Colormap(:$(t.name))")

apply(t::Colormap, x::AbstractArray) = get(t.colormap, x, :clamp)

#=====================================#
# Coupling to normalization functions #
#=====================================#

# Kind of colormap a normalization is meant to be paired with.
# Normalizations of unknown kind return `nothing` and are not checked.
function colormap_kind(n::AbstractNormalization)
    signed = issigned(n)
    isnothing(signed) && return nothing
    return signed ? :diverging : :sequential
end

# ColorSchemes.jl only describes the kind of a colormap in its free-text notes.
# Colormaps of unknown kind return `nothing` and are not checked.
function colormap_kind(c::Colormap)
    notes = c.colormap.notes
    occursin(r"diverging"i, notes) && return :diverging
    occursin(r"sequential"i, notes) && return :sequential
    return nothing
end

function default_colormap(n::AbstractNormalization)
    return colormap_kind(n) == :diverging ? Colormap(:berlin) : Colormap(:batlow)
end

function check_colormap(n::AbstractNormalization, c::Colormap)
    expected, actual = colormap_kind(n), colormap_kind(c)
    if !isnothing(expected) && !isnothing(actual) && expected != actual
        @warn "$n is meant to be paired with a $expected colormap, but ColorSchemes.jl describes $c as $actual. Consider using $(default_colormap(n)) instead."
    end
    return nothing
end

# Colormaps are checked against the preceding normalization when a pipeline is composed.
function compose(n::AbstractNormalization, c::Colormap)
    check_colormap(n, c)
    return Pipeline(n, c)
end
function compose(p::Pipeline, c::Colormap)
    i = findlast(t -> t isa AbstractNormalization, p.transforms)
    isnothing(i) || check_colormap(p.transforms[i], c)
    return Pipeline(p.transforms..., c)
end
