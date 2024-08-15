import Bold from "@tiptap/extension-bold";
import BulletList from "@tiptap/extension-bullet-list";
import Document from "@tiptap/extension-document";
import HardBreak from "@tiptap/extension-hard-break";
import Italic from "@tiptap/extension-italic";
import Link from "@tiptap/extension-link";
import ListItem from "@tiptap/extension-list-item";
import OrderedList from "@tiptap/extension-ordered-list";
import Paragraph from "@tiptap/extension-paragraph";
import Placeholder from "@tiptap/extension-placeholder";
import Strike from "@tiptap/extension-strike";
import Text from "@tiptap/extension-text";
import TextAlign from "@tiptap/extension-text-align";
import Underline from "@tiptap/extension-underline";

export const extensions = (inputTarget) => [
  Bold,
  BulletList,
  Document,
  HardBreak,
  Italic,
  Link.configure({ openOnClick: false }),
  ListItem,
  OrderedList,
  Paragraph,
  Placeholder.configure({ placeholder: inputTarget.placeholder }),
  Strike,
  Text,
  TextAlign.configure({ types: ["heading", "paragraph"] }),
  Underline,
];
