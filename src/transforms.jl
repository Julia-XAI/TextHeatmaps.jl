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
"""
struct Colormap <: AbstractTransform
    name::Symbol
    colormap::ColorScheme
end
Colormap(name::Symbol) = Colormap(name, colorschemes[name])
Colormap() = Colormap(:batlow)

Base.show(io::IO, t::Colormap) = print(io, "Colormap(:$(t.name))")

apply(t::Colormap, x::AbstractArray) = get(t.colormap, x, :clamp)
