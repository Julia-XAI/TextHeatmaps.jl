# TextHeatmaps.jl

## Version `v2.0.0`
* ![BREAKING][badge-breaking] Support XAIBase v5, requiring XAIBase `v5.2`:
  * heatmap `Attribution`s instead of `Explanation`s
  * default pipelines are chosen by the attribution pooling function `attr.pooling`
    and can be inspected using `TextHeatmaps.default_pipeline(attr)`:
    unsigned poolings use `ExtremaNormalization` and `:batlow`,
    signed poolings use `CenteredNormalization` and `:berlin`
  * remove the `:attribution`, `:sensitivity` and `:cam` presets
* ![BREAKING][badge-breaking] Heatmaps are customized using pipelines of transforms, mirroring VisionHeatmaps.jl:
  * `heatmap(x, tokens, pipeline)` replaces the keyword arguments `colorscheme` and `rangescale`, e.g.
    `heatmap(x, tokens, ExtremaNormalization() |> Colormap(:inferno))`
  * `ExtremaNormalization()` and `CenteredNormalization()` replace the rangescales `:extrema` and `:centered`
  * `Colormap(name)` applies colormaps from ColorSchemes.jl
  * `AbstractTransform`, `Pipeline`, attribution pooling and normalization functions are re-exported from XAIBase
  * remove the keyword argument `reduce`, which had no effect
* ![BREAKING][badge-breaking] `heatmap` requires vectors of tokens.
  The internal `TextHeatmap` no longer stores values
* ![Feature][badge-feature] Pool attributions with a feature dimension,
  following the convention `(features, input_length, batchsize)`.
  Pooling functions like `NormPooling()` and `SumPooling()` are used as pipeline steps
* ![Feature][badge-feature] Heatmap batches of arrays by passing a vector containing vectors of tokens.
  `BatchedNormalization(normalization)` normalizes all heatmaps in a batch to a shared value range
* ![Feature][badge-feature] Add `heatmap(input, analyzer, text)`, which computes and heatmaps an `Attribution`
* ![Feature][badge-feature] Warn when a pipeline pairs `ExtremaNormalization` with a diverging colormap
  or `CenteredNormalization` with a sequential colormap

## Version `v1.3.0`
* ![Enhancement][badge-enhancement] Add line wrapping in HTML output ([#9])

## Version `v1.2.2`
* ![Maintenance][badge-maintenance] Update dependencies

## Version `v1.2.1`
* ![Feature][badge-feature] Add XAIBase dependency ([#4], [#5])

## Version `v1.1.0`
* ![Feature][badge-feature] Access color schemes through their symbols ([#3])

## Version `v1.0.1`
* ![Enhancement][badge-enhancement] Restrict argument types of `heatmap` function ([e5eaa83][commit-e5eaa83])

## Version `v1.0.0`
* Initial release

[#9]: https://github.com/Julia-XAI/TextHeatmaps.jl/pull/9
[#5]: https://github.com/Julia-XAI/TextHeatmaps.jl/pull/5
[#4]: https://github.com/Julia-XAI/TextHeatmaps.jl/pull/4
[#3]: https://github.com/Julia-XAI/TextHeatmaps.jl/pull/3

[commit-e5eaa83]: https://github.com/Julia-XAI/TextHeatmaps.jl/commit/e5eaa83

<!--
# Badges
![BREAKING][badge-breaking]
![Deprecation][badge-deprecation]
![Feature][badge-feature]
![Enhancement][badge-enhancement]
![Bugfix][badge-bugfix]
![Experimental][badge-experimental]
![Maintenance][badge-maintenance]
![Documentation][badge-docs]
-->

[badge-breaking]: https://img.shields.io/badge/BREAKING-red.svg
[badge-deprecation]: https://img.shields.io/badge/deprecation-orange.svg
[badge-feature]: https://img.shields.io/badge/feature-green.svg
[badge-enhancement]: https://img.shields.io/badge/enhancement-blue.svg
[badge-bugfix]: https://img.shields.io/badge/bugfix-purple.svg
[badge-security]: https://img.shields.io/badge/security-black.svg
[badge-experimental]: https://img.shields.io/badge/experimental-lightgrey.svg
[badge-maintenance]: https://img.shields.io/badge/maintenance-gray.svg
[badge-docs]: https://img.shields.io/badge/docs-orange.svg
