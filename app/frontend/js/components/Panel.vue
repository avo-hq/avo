<template>
  <div>
    <view-header>
      <template #heading>
        <slot name="heading"/>
      </template>

      <template #tools>
        <div class="mb-6">
          <slot name="tools"/>
        </div>
      </template>
    </view-header>

    <div class="relative bg-white rounded-xl shadow-xl mb-8 min-h-28">
      <slot name="content"/>
    </div>

    <div class="relative mb-8">
      <slot name="bare-content"/>
    </div>

    <div class="flex justify-end w-full">
      <div>
        <slot name="footer"/>
      </div>
    </div>
  </div>
</template>
