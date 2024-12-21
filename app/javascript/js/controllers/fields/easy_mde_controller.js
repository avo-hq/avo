import { Controller } from "@hotwired/stimulus";
import EasyMDE from "easymde";
import { DirectUpload } from "@rails/activestorage";

export default class extends Controller {
  static targets = ["element"];

  get view() {
    return this.elementTarget.dataset.view;
  }

  get componentOptions() {
    try {
      return JSON.parse(this.elementTarget.dataset.componentOptions);
    } catch (error) {
      return {};
    }
  }

  connect() {
    console.log("Hello from the connection")
    
    const options = {
      element: this.elementTarget,
      spellChecker: this.componentOptions.spell_checker,
      autoRefresh: { delay: 500 },
    };

    if (this.view === "show") {
      options.toolbar = false;
      options.status = false;
    }


    if (this.componentOptions.image_upload) {
      this._configureImageUploads(options);
    }

    const easyMde = new EasyMDE(options);
    if (this.view === "show") {
      easyMde.codemirror.options.readOnly = true;
    }
  }

  _configureImageUploads(options) {
    options.uploadImage = true;
    options.imageUploadEndpoint = this.elementTarget.dataset.uploadUrl;
    options.imageUploadFunction = this._handleImageUpload.bind(this);
    options.imageAccept = "image/*";
    options.previewImagesInEditor = true;
    options.toolbar = this.toolbarItems;
    return options;
  }

  _handleImageUpload(file, onSuccess, onError) {
    const upload = new DirectUpload(file, this.elementTarget.dataset.uploadUrl);
    upload.create((error, blob) => {
      if (error) return onError(error);
      const imageUrl = this._encodedImageUrl(blob);
      onSuccess(imageUrl);
    });
  }

  _encodedImageUrl(blob) {
    return `/rails/active_storage/blobs/redirect/${
      blob.signed_id
    }/${encodeURIComponent(blob.filename)}`;
  }

  get toolbarItems() {
    const baseItems = [
      "bold",
      "italic",
      "heading",
      "|",
      "quote",
      "unordered-list",
      "ordered-list",
      "|",
      "link",
      "image",
    ];

    const uploadImageItem = this.componentOptions.image_upload
      ? [
          {
            name: "upload-image",
            action: EasyMDE.drawUploadedImage,
            className: "fa fa-file-picture-o",
            title: "Upload & insert image",
          },
        ]
      : [];

    return [
      ...baseItems,
      ...uploadImageItem,
      "|",
      "preview",
      "side-by-side",
      "fullscreen",
      "|",
      "guide",
    ];
  }
}
