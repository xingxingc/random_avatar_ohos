export class  RandomSource {
  title :string
  icon :string
  path :string

  constructor(title :string, icon :string, path :string) {
    this.title = title
    this.icon = icon
    this.path = path
  }
}

export enum kRandomPages {
  shapeStack = 'ShapeStackPage',
  ugly = 'UglyPage',
  duck = 'DuckPage',
  blobby = 'BlobbyPage',
  smile = 'SmilePage',
  kawaii = 'KawaiiPage',
}

export const kRandomList = [
  new RandomSource('卡哇伊', 'random_kawaii', kRandomPages.kawaii),
  new RandomSource('萌眼小团', 'random_blobby', kRandomPages.blobby),
  new RandomSource('简单微笑', 'random_smile', kRandomPages.smile),
  new RandomSource('几何堆叠', 'random_shape_stack', kRandomPages.shapeStack),
  new RandomSource('丑头像', 'random_ugly', kRandomPages.ugly),
  new RandomSource('无聊鸭', 'random_duck', kRandomPages.duck),
]